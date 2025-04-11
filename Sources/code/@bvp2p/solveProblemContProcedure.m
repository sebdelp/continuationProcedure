function  obj=solvePbContProcedure(obj,sol,params,fixedParams)
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
    if sol.iflbvp~=0
        error('SingJac');
    end
    if ~obj.solValidationFcn(sol,params,fixedParams)
        error('Solution is discarded by the validation function');
    else
        obj.lastSolution=sol;
        obj.lastIterSuccess=sol.iflbvp==0;
    end
    obj.lastMessage='success';
catch Error
    obj.lastIterSuccess = false;
    obj.lastMessage = [Error.identifier ':' Error.message];
    if ~contains(Error.identifier,'SingJac')&&~strcmp(Error.message,'Solution is discarded by the validation function')
        % The error is not due to a solver issue
        rethrow(Error);
    end
end

% Data are now available
obj.lastSolAvailable=true;
end