function [EVrange, scriptVer] = computeEVRange(frontalArea, dragCoefficient, motorPowerMax, enginePowerMax, batteryCapacity, fuelCapacity, totalMass)
    
    scriptVer = 2;
    
    %% Set Fuel Capacity = 0
    fuelCapacity = 0;

    %% Define Constants (DO NOT ALTER)
    airDensity = 1.225;         % kg/m^3 (air density at sea level)
    gravity = 9.81;             % m/s^2 (acceleration due to gravity)
    rollingCoefficient = 0.01;  % unitless (rolling resistance coefficient)
    vehicleBaseMass = 1800;     % kg (base mass of vehicle)   
    accessoryPower = 1000;      % assuming a constant accessory load (W)
    accelerationPenaltyFactor = 0.05; % [J/(W·s)] Extra energy consumption per Watt increase in power during acceleration
    regenEfficiency = 0.7;      % regenerative braking efficiency (70% of braking energy recovered)
    rangeLossFactor = 0.85;     % a real-world range loss adjustment factor accounting for other losses

    %% Compute Additional Masses (Interactions between Design Variables)
    motorMassFactor = 0.5;      % kg increase per kW of motor power (estimated)
    engineMassFactor = 1.5;     % kg increase per kW of engine power (estimated)
    batteryMassFactor = 7;      % kg increase per kWh of battery capacity (estimated)
    fuelMassFactor = 0.75;      % kg increase per liter of fuel (approximate)
    
    additionalMassMotor = motorMassFactor * motorPowerMax;
    additionalMassEngine = engineMassFactor * enginePowerMax;
    additionalMassBattery = batteryMassFactor * batteryCapacity;
    additionalMassFuel = fuelMassFactor * fuelCapacity;
    
    vehicleMass = vehicleBaseMass + additionalMassMotor + additionalMassEngine + additionalMassBattery + additionalMassFuel;

    % Drivetrain efficiency as a function of speed (estimated)
    % Heavier vehicles may suffer additional drivetrain losses.
    efficiencyFunction = @(speed) max(0.95 - 0.0005 * speed - 0.00005 * vehicleMass, 0.70);

    % Rolling resistance as a function of speed
    C_rr0 = rollingCoefficient;   % Base rolling resistance
    C_rr1 = 0.0001;               % Speed-dependent term (estimated)
    
    %% Import Drive Cycle Profile
    % Specify the filename
    filename = 'WLTC_Class3.csv';
    
    % Read the data into a table
    data = readtable(filename);
    
    % Extract time and speed columns
    time = data{:, 1};  
    speed = data{:, 2}; 
    
    %% Simulate Energy Consumption over the Drive Cycle (DO NOT ALTER)
    totalEnergyConsumed = 0;  % Total net energy (J)
    totalDistance = 0;        % Total distance (m)
    prevPower = 0;            % Previous time-step power (W)
    
    for i = 1:length(time)-1
        % Compute the time stpe based on the data
        timeStep = time(i+1)-time(i);

        % Compute acceleration during this time step (m/s^2)
        acceleration = (speed(i+1) - speed(i)) / timeStep;
        
        % Resistive forces
        dragForce = 0.5 * dragCoefficient * airDensity * frontalArea * speed(i)^2;
        rollingResistance = (C_rr0 + C_rr1 * speed(i)) * vehicleMass * gravity;
        
        % Required force: inertial + drag + rolling resistance
      
        requiredForce = (vehicleMass * acceleration + dragForce + rollingResistance);
        
        if requiredForce >= 0
            % Acceleration or steady-state:
            powerRequired = requiredForce * speed(i); % (W)
            baseEnergy = (powerRequired / efficiencyFunction(speed(i))) * timeStep;
            
            % Extra penalty if power output increases (transient losses)
            if i == 1
                powerChange = 0;
            else
                powerChange = max(0, powerRequired - prevPower);
            end
            extraPenalty = accelerationPenaltyFactor * powerChange * timeStep;
            
            energyStep = baseEnergy + extraPenalty + accessoryPower * timeStep;
            prevPower = powerRequired;  % update for next step
        else
            % Deceleration:
            brakingPower = -requiredForce * speed(i);  % (W)
            % Regenerative recovery reduced by additional deceleration losses
            energyStep = - regenEfficiency * brakingPower * timeStep;
            prevPower = 0;  % reset power during braking
        end
        
        totalEnergyConsumed = totalEnergyConsumed + energyStep;
        totalDistance = totalDistance + speed(i) * timeStep;
    end
    
    % Avoid nonphysical (negative) total consumption.
    if totalEnergyConsumed < 0
        totalEnergyConsumed = 1e-6;
    end
    
    % Energy consumption per meter (J/m)
    energyPerMeter = totalEnergyConsumed / totalDistance;
    
    %% Compute Total Available Energy in the Vehicle
    % Battery: 1 kWh = 3.6e6 J
    batteryEnergy = batteryCapacity * 3.6e6;
    % Fuel: assume ~9 kWh usable energy per liter.
    fuelEnergy = fuelCapacity * 9 * 3.6e6;
    totalAvailableEnergy = batteryEnergy + fuelEnergy;
    
    %% Estimate Range
    % Total range (m) = available energy / energy consumption per meter.
    estimatedRangeMeters = totalAvailableEnergy / energyPerMeter;
    
    % Convert range to miles (1 m = 0.000621371 miles)
    EVrange = estimatedRangeMeters * 0.000621371;

    % apply the range loss scaling factor
    EVrange =  EVrange * rangeLossFactor;

end