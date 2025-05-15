function [V_top, scriptVer] = computeTopSpeed(frontalArea, dragCoefficient, motorPowerMax, enginePowerMax, batteryCapacity, fuelCapacity, totalMass)
    
    scriptVer = 1;
    %% Constants (Do NOT alter)
    airDensity = 1.225;         % kg/m^3 (air density at sea level)
    gravity = 9.81;             % m/s^2 (acceleration due to gravity)
    vehicleBaseMass = 1800;     % kg 
    rollingCoefficient = 0.01;  % unitless

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
    
    %% Solving Top Speed (DO NOT ALTER)
    % Convert power to watts
    totalPower = (motorPowerMax + enginePowerMax) * 1000; % Convert kW to W

    % Define power balance function to solve for V
    powerBalance = @(speed) ( ...
        (0.5 * dragCoefficient * airDensity * frontalArea * speed.^3) + ...         % Aerodynamic drag power
        ((C_rr0 + C_rr1 * speed) * (vehicleMass * gravity + 0.5 * dragCoefficient * airDensity * frontalArea * speed.^2) * speed) ... % Rolling resistance + downforce effect
        ) / efficiencyFunction(speed) - totalPower;

    % Solve for V_top using fsolve
    options = optimset('Display','off');
    V_top = fsolve(powerBalance, 30, options);  % Initial guess: 30 m/s (~108 km/h)

    % convert top speed into miles/hour
    V_top = 2.23694*V_top; 

end