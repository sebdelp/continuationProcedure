function checkFields(obj,p1,p2,p1name,p2name)
% Check that both p1 & p2 structure have the same fields
% and that fields have correct type


fields=fieldnames(p1);
for i=1:length(fields)
    if ~isfield(p2,fields{i})
        error('Field "%s" is not available in %s',fields{i},p2name);
    end
    if ~isnumeric(p1.(fields{i}))
        error('Field "%s" should have a numerical value in %s',fields{i},p1name);
    end
    if ~isnumeric(p2.(fields{i}))
        error('Field "%s" should have a numerical value in %s',fields{i},p2name);
    end
end

fields=fieldnames(p2);
for i=1:length(fields)
    if ~isfield(p1,fields{i})
        error('Field "%s" is not available in %s',fields{i},p1name);
    end
end

fields=fieldnames(p2);
for i=1:length(fields)
    if ~isempty(obj.fixedParams) && isfield(obj.fixedParams,fields{i})
        error('Field "%s" is available in both the variable %s and %s',fields{i},p1name,p2name);
    end
end
end