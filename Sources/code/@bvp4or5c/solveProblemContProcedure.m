function  obj=solveProblemContProcedure(obj,sol,params,fixedParams)
% Try to solve current problem
arguments
    obj
    sol      struct
    params   struct
    fixedParams struct
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

try 
    % Try to solve the problem using the provided parameters
    if isempty(bvpOptions)
        % No options
        obj.lastSolution=obj.solverFcn(fdyn,bcfun,sol);
    else
        % With options
        obj.lastSolution=obj.solverFcn(fdyn,bcfun,sol,bvpOptions);
    end
    obj.lastIterSuccess=true;
    obj.lastMessage='success';
    if obj.catchMeshPointsError
        warning(originalWarningState);
    end
catch Error
    obj.lastIterSuccess = false;
    obj.lastMessage = [Error.identifier ':' Error.message];
    if obj.catchMeshPointsError
        warning(originalWarningState);
    end

    if ~contains(Error.identifier,'SingJac')
        % The error is not due to a solver issue
        rethrow(Error);
    end
end

% Data are now available
obj.lastSolAvailable=true;
end