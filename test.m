filePath = 'C:\Users\wshi2\OneDrive - Loughborough University\hsuv_mms\CSS_BOM_Parts_Catalogue.xlsx';
disp(filePath)
disp(exist(filePath,'file'))

[status, sheets] = xlsfinfo(filePath);
if isempty(sheets)
    error('Couldn''t read any sheets—file might be locked or not a valid Excel workbook.');
end
fprintf('Available sheets:\n');
disp(sheets')

%id = 3;
%opts = detectImportOptions('CSS_BOM_Parts_Catalogue.xlsx', 'Sheet', 'Lookup');
%opts = setvartype(opts, 'ID', 'double');
%opts = setvartype(opts, 'Cost', 'double');
%lookupTbl = readtable('CSS_BOM_Parts_Catalogue.xlsx', opts, 'Sheet', 'Lookup');
%lookupParts(lookupTbl, id);