function price = getTotalCost(battery_ID, fuelTank_ID, ICE_ID, motor_ID, wheel_ID)
    
    %% User-adjustable settings
    % sheet with ID,Name,Cost
    reportFile = "cost_table.xlsx";
    reportSheet = "Sheet1"        ;         % sheet to populate
    startRow     = 2;      
    
    [ok,msg,msgid] = fileattrib(reportFile,'+w');  
    if ~ok
        warning('Could not clear write-protection: %s', msg);
    end% first data row in report
    %% 1) List the worksheets in the file
    fileName = 'CSS_BOM_Parts_Catalogue.xlsx';
    [status, sheets] = xlsfinfo(fileName);
    if isempty(sheets)
        error('No sheets found; is the file open elsewhere or corrupted?')
    end
    disp('Worksheets:')
    disp(sheets')
    
    %% 2) Pick the correct sheet—e.g. if it’s the first sheet:
    sheetName = sheets{1};  
    
    %% 3) Create import options forcing ID and Cost to numeric
    opts = detectImportOptions(fileName, 'Sheet', sheetName);
    opts = setvartype(opts, 'partNumber',   'double');  
    opts = setvartype(opts, 'cost', 'double');  
    
    %% 4) Read the table
    lookupTbl = readtable(fileName, opts, 'Sheet', sheetName);



    %% Excel calculation
    excel = actxserver('Excel.Application');
    excel.Visible = true;
    wb = excel.Workbooks.Open(fullfile(pwd, reportFile), 0, false);
    ws = wb.Sheets.Item(reportSheet);

    % — after opening your workbook & sheet (step 2) —
    % ws = wb.Sheets.Item(reportSheet);
    
    % — Step 3) Check for existing headers in A1:J1 —
    hdrRange = ws.Range('A1:K1').Value;
    
    % Determine if any cell in A1:J1 is non‐empty
    if iscell(hdrRange)
        emptyFlags   = cellfun(@(x) isempty(x), hdrRange);
        headerExists = any(~emptyFlags);
    else
        headerExists = any(~isnan(hdrRange));
    end
    
    % If no header, write your custom titles
    if ~headerExists
        headers = {...
          'batteryName',  'batteryCost',  ...
          'fuelTankName', 'fuelTankCost', ...
          'ICEName',      'ICECost',      ...
          'motorName',    'motorCost',    ...
          'wheelID',      'wheelCost',    ...
          'total_price'
        };
        % Write them in one go across A1:J1
        ws.Range('A1').Resize(1, numel(headers)).Value = headers;
    end
    
   % Use Excel's End(xlUp) to jump up from the bottom of the sheet
    xlUp = -4162;  
    lastRow = ws.Range( sprintf('A%d', ws.Rows.Count) ).End(xlUp).Row;
    
    % If lastRow is still 1 (only header exists), start at row 2, else next row
    firstDataRow = 2;
    if lastRow < firstDataRow
        writeRow = firstDataRow;
    else
        writeRow = lastRow + 1;
    end



    partIDs = [battery_ID, fuelTank_ID, ICE_ID, motor_ID, wheel_ID];
    nameCols = {'A','C','E','G','I'};
    costCols = {'B','D','F','H','J'};
    
    for k = 1:numel(partIDs)
        pid = partIDs(k);
        
        % Lookup name & cost via your single‐ID function
        [partName, partCost] = lookupParts(lookupTbl, pid);
        
        % Build the cell addresses (e.g. 'A2','B2','C2', etc.)
        nameCell = sprintf('%s%d', nameCols{k}, writeRow);
        costCell = sprintf('%s%d', costCols{k}, writeRow);
        
        % Write into Excel
        ws.Range(nameCell).Value = partName;
        ws.Range(costCell).Value = partCost;
    end

    % 2) Build the SUM formula for the five cost columns at writeRow
    %    costCols = {'B','D','F','H','J'};
    sumFormula = sprintf('=SUM(%s%d,%s%d,%s%d,%s%d,%s%d)', ...
        costCols{1}, writeRow, ...
        costCols{2}, writeRow, ...
        costCols{3}, writeRow, ...
        costCols{4}, writeRow, ...
        costCols{5}, writeRow);
    
    % 3) Insert the formula into column K
    ws.Range(sprintf('K%d', writeRow)).Formula = sumFormula;
    
    % 4) (Optional) force Excel to refresh calculated cells
    excel.CalculateFull;
    wb.Save;
    %wb.Close(false)
    
    price = ws.Range( sprintf('K%d', lastRow) ).Value;
    disp(price)
    %excel.Quit;
end
