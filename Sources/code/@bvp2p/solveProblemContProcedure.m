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

try 
    % Try to solve the problem using the provided parameters
    if isempty(bvpOptions)
        % No options
        sol=bvptwp(fdyn,bcfun,sol);
    else
        % With options
        sol=bvptwp(fdyn,bcfun,sol,bvpOptions);
    end
    obj.lastSolution=sol;
    obj.lastIterSuccess=sol.iflbvp==0;
    if sol.iflbvp~=0
        error('SingJac');
    end
    obj.lastMessage='success';
catch Error
    obj.lastIterSuccess = false;
    obj.lastMessage = [Error.identifier ':' Error.message];
    if ~contains(Error.identifier,'SingJac')
        % The error is not due to a solver issue
        rethrow(Error);
    end
end

% Data are now available
obj.lastSolAvailable=true;
end