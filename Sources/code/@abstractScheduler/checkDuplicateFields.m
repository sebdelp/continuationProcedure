function checkDuplicateFields(obj,p1,p2,p1name,p2name)
% This check that both parameters p1 and p2 does not contains the same
% field
% This is typically used to check that paramStart (or paramEnd) fields are
% not duplicate with fixedParams
if isempty(p1) || isempty(p2)
    % One of the structure is empty, nothing to check
    return
end

fields1=fieldnames(p1);
fields2=fieldnames(p2);

for i=1:length(fields1)
    if isfield(p2,fields1{i})
        error('The field "%s" is present in both %s and %s', fields1{1},p1name,p2name);
    end
end

for i=1:length(fields2)
    if isfield(p1,fields2{i})
        error('The field "%s" is present in both %s and %s', fields2{1},p1name,p2name);
    end
end

end