function [time_0to60, scriptVer] = computeAcceleration(frontalArea, dragCoefficient, motorPowerMax, enginePowerMax, batteryCapacity, fuelCapacity)
    
    scriptVer = 1;
    %% Define Constants (DO NOT ALTER)
    airDensity = 1.225;     % kg/m^3 (air density at sea level)
    gravity = 9.81;         % m/s^2 (acceleration due to gravity)
    vehicleBaseMass = 1800; % kg
    rollingCoefficient = 0.01;  % unitless
    maxSpeed = 60 * 1609.34 / 3600;     % 60 mph to m/s (convert to m/s)
    timeStep = 0.001;       % Time step for simulation (in seconds)\
    tireFriction = 0.9;
    
    %% Interactions between Design Variables
    % Estimate the vehicle true weight using linear factors
    motorMassFactor = 0.5;  % kg increase per kW of motor power (estimated)
    engineMassFactor = 1.5;   % kg increase per kW of engine power (estimated)
    batteryMassFactor = 7;  % kg increase per kWh of battery capacity (estimated)
    fuelMassFactor = 0.75;  % kg increase per litre of gasoline fuel (approximate)
    
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
    
    %% Simulate 0-to-60 Time (DO NOT ALTER)

    % Convert power to watts
    totalPower = (motorPowerMax + enginePowerMax) * 1000; % Convert kW to W

    % Initialize variables
    speed = 0;          % Initial speed in m/s
    acceleration = 0;   % Initial acceleration (m/s^2)
    time = 0;           % Time in seconds

    % Maximum tractive force due to tire traction
    maxTractionForce = tireFriction * vehicleMass * gravity; % Tire grip (friction limit)

    % Simulation loop: Calculate speed at each time step
    while speed < maxSpeed
        % Compute tractive force at current speed (using total power divided by speed)
        if speed == 0
            tractiveForce = totalPower / (speed + 0.001); % Avoid division by zero at very low speeds
        else
            tractiveForce = (efficiencyFunction(speed) * totalPower) / speed; % Power divided by current speed
        end
 
        % Apply the traction limit (max tire force)
        if tractiveForce > maxTractionForce
            tractiveForce = maxTractionForce; % Cap to maximum tire traction
        end

        % Compute resistive forces
        dragForce = 0.5 * dragCoefficient * airDensity * frontalArea * speed^2;
        rollingResistance = (C_rr0 + C_rr1 * speed) * vehicleMass * gravity;

        % Compute net force (tractive force minus resistive forces)
        netForce = tractiveForce - (dragForce + rollingResistance);

        % Compute acceleration (Newton's second law)
        acceleration = netForce / vehicleMass;

        % Update speed and time
        speed = speed + acceleration * timeStep;  % Speed at next time step
        time = time + timeStep;                   % Increment time
    end

    % Final time to reach 60 mph (in seconds)
    time_0to60 = time;
    
end