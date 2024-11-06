function p=createStructureFromVariable(varargin)
% This helper function create a structure with the provided variable
% exemple : createStructureFromVariable(a,b)
% returns a structure p.a and p.b with values a & b
p=struct.empty;
for i=1:nargin
    if isempty(inputname(i)) || ~isvarname(inputname(i))
        error('Parameter n°%i is not a valid variable name');
    end
    if ~isempty(p) && isfield(p(1),inputname(i))
        error('The variable %s is passed twice');
    end
    p(1).(inputname(i))=evalin('caller',inputname(i));
end
end