classdef ivp
    % Solve an initial value problem using an ode solver
    properties (SetAccess=private,GetAccess=public)
        generateFodeFcn
        odeOptions
    end
    properties (SetAccess=private, GetAccess=private)
        solverFcn
    end


    methods

        function obj=ivp(solver,generateFodeFcn,options)
            arguments
                solver                   (1,1) string {mustBeMember(solver,{'ode45','ode23','ode78','ode89','ode113','ode115s','ode23s','ode23t','ode23tb'})}
                generateFodeFcn          function_handle
              
                options.odeOptions        struct = []
            end


            % Check bvp options
            if  ~isempty(options.odeOptions)
                obj.odeOptions=options.odeOptions;
                if ~isempty(options.fcnForBvpOptions)
                    error('fcnForBvpOptions and bvpOptions cannot be specified at the same time');
                end

            end

            % Store object values
            obj.generateFodeFcn=generateFodeFcn;
            

            switch solver
                case 'ode45'
                    obj.solverFcn=@ode45;
                case 'ode23'
                    obj.solverFcn=@ode23;
                case 'ode78'
                    obj.solverFcn=@ode78;
                case 'ode89'
                    obj.solverFcn=@ode89;
                case 'ode113'
                    obj.solverFcn=@ode113;

                case 'ode115s'
                    obj.solverFcn=@ode113;
                case 'ode23s'
                    obj.solverFcn=@ode23s;
                case 'ode23t'
                    obj.solverFcn=@ode23t;
                case 'ode23tb'
                    obj.solverFcn=@ode23tb;
            end

        end


    end
    methods
        % Solve a problem for a given initial solution and parameters
        % values and manage the continuation procedure fields
        % (lastSolution, lastIterSuccess, lastMessage)
        sol=solveProblem(obj,tspan,y0,params,fixedParams)

    end
end