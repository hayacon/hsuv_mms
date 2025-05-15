function [battery_xloc, battery_yloc, battery_zloc, ...
          fuelTank_xloc, fuelTank_yloc, fuelTank_zloc, ...
          ICE_xloc, ICE_yloc, ICE_zloc ...
          ] ...
          = solidworksSim(battery_ID, fuelTank_ID, ICE_ID, motor_ID, wheel_ID)

    % Battery - near center or under floor
    battery_xloc = randInRange(-0.5, 0.5);
    battery_yloc = randInRange(0.3, 0.5);
    battery_zloc = randInRange(-0.2, -0.1);
    
    % Fuel Tank - rear under trunk
    fuelTank_xloc = randInRange(-0.3, 0.3);
    fuelTank_yloc = randInRange(-1.2, -1.0);
    fuelTank_zloc = randInRange(-0.3, -0.1);

    % ICS (ICE system) - front engine bay
    ICE_xloc = randInRange(-0.4, 0.4);
    ICE_yloc = randInRange(1.0, 1.2);
    ICE_zloc = randInRange(0.0, 0.2);
    


end

function value = randInRange(minVal, maxVal)
    value = minVal + (maxVal - minVal) * rand();
end
