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

% Try to solve the problem using the provided parameters
if isempty(bvpOptions)
    % No options
    sol=obj.solverFcn(fdyn,bcfun,sol);
else
    % With options
    sol=obj.solverFcn(fdyn,bcfun,sol,bvpOptions);
end

end