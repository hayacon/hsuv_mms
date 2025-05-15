function [battery_xloc, battery_yloc, battery_zloc, ...
          fuelTank_xloc, fuelTank_yloc, fuelTank_zloc,...
          ICS_xloc, ICS_yloc, ICS_zloc,...
          motor_xloc, motor_yloc, motor_zloc,...
          wheel_xloc, wheel_yloc, wheel_zloc] ...
          = solidworksSim(battery_ID, fuelTank_ID, ICE_ID, motor_ID, wheel_ID)

    % Battery - near center or under floor
    battery_xloc = randInRange(-0.5, 0.5);
    battery_yloc = randInRange(0.3, 0.5);
    battery_zloc = randInRange(-0.2, -0.1);
    
    % Fuel Tank - near rear
    fuelTank_xloc = randInRange(-0.3, 0.3);
    fuelTank_yloc = randInRange(-1.2, -1.0);
    fuelTank_zloc = randInRange(-0.3, -0.1);

    % ICS (ICE system) - engine bay front
    ICS_xloc = randInRange(-0.4, 0.4);
    ICS_yloc = randInRange(1.0, 1.2);
    ICS_zloc = randInRange(0.0, 0.2);
    
    % Motor (assuming electric assist, front or mid)
    motor_xloc = randInRange(-0.3, 0.3);
    motor_yloc = randInRange(0.8, 1.0);
    motor_zloc = randInRange(-0.1, 0.2);
    
    % Wheel - place as a general point (can be detailed further by each wheel)
    wheel_xloc = randInRange(0.7, 0.8);  % assuming front-right wheel as example
    wheel_yloc = randInRange(1.2, 1.3);
    wheel_zloc = randInRange(-0.4, -0.3);

end

function value = randInRange(minVal, maxVal)
    value = minVal + (maxVal - minVal) * rand();
end
