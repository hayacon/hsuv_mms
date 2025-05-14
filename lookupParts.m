function [name, cost] = lookupParts(lookupTable, id)
    
    idx = find(lookupTable.partNumber == id, 1);
    if isempty(idx)
        name = '';
        cost = NaN;
    else
        rawName = lookupTable.Name(idx);
        if iscell(rawName)
            name = rawName{1};
        elseif isstring(rawName)
            name = char(rawName);
        else 
            name = rawName;
        end 
        cost = lookupTable.cost(idx);
    end
end