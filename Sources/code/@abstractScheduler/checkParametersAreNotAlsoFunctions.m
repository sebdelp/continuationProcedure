function checkParametersAreNotAlsoFunctions(obj,params)
% This function checks wether or not params fields are also function in
% Matlab path. The issue comes from arguments whose names are also
% function.
% Matlab is now giving priority to functions and so anonymous function
% generate errors
for noParam=1:length(params)
    param=params{noParam};
    fields=fieldnames(param);
    for noField=1:length(fields)
      if any(exist(fields{noField},'file')==[2 5])
        error(['The parameter "%s" is also the name of a function. As a result you cannot use it as anonymous function parameter.\n' ...
               'Suggested action : change parameter name\n' ...
               'Function that causes trouble  : ""%s".' ...
               'When creating the scheduler, use options "doNotCheckParameterIsAFunction","true" to remove this check'], ...
            fields{noField},which(fields{noField}));
      end
    end
end
end
