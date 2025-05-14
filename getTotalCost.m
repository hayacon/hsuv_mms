function price = getTotalCost(battery_ID, fuelTank_ID, ICE_ID, motor_ID, wheel_ID)
    
    excel = actxserver('Excel.Application');
    excel.Visible=true;
