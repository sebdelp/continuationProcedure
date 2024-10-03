function  sol=solveProblem(obj,tspan,y0,params,fixedParams)
% Try to solve current problem
arguments
    obj
    tspan   (1,2) double
    y0      double
    params   struct=[]
    fixedParams struct=[]
end

fdyn= obj.generateFodeFcn(params, fixedParams);

% Try to solve the problem using the provided parameters
if isempty(obj.odeOptions)
    % No options
    sol=obj.solverFcn(fdyn,tspan,y0);
else
    % With options
    sol=obj.solverFcn(fdyn,tspan,y0,obj.odeOptions);
end

end