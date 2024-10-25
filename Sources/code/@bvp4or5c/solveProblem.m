function  sol=solveProblem(obj,sol,params,fixedParams)
% Try to solve current problem
arguments
    obj
    sol      struct
    params   struct=[]
    fixedParams struct=[]
end

if ~isempty(obj.fcnForBvpOptions)
    bvpOptions=obj.fcnForBvpOptions(params,fixedParams);
else
    bvpOptions=obj.bvpOptions;
end
fdyn= obj.generateFodeFcn(params, fixedParams);
bcfun=obj.generateBCFcn(params, fixedParams);

if obj.catchMeshPointsError
    % This is an undocumented way to catch warnings
    originalWarningState=warning('query','MATLAB:bvp5c:RelTolNotMet');
    warning('error','MATLAB:bvp5c:RelTolNotMet');
end

% Try to solve the problem using the provided parameters
try
if isempty(bvpOptions)
    % No options
    sol=obj.solverFcn(fdyn,bcfun,sol);
else
    % With options
    sol=obj.solverFcn(fdyn,bcfun,sol,bvpOptions);
end
catch Error
    % Restaure warning state
    if obj.catchMeshPointsError
        warning(originalWarningState);
    end
    rethrow(Error);
end

if obj.catchMeshPointsError
    % Restaure warning state
    warning(originalWarningState);
end
end