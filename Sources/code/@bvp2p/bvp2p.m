classdef bvp2p < abstractContProcedureProblem
    % Solve a boundary value problem usinbg bvptwp
    properties (SetAccess=public,GetAccess=public)
        generateFodeFcn
        generateBCFcn
        fcnForBvpOptions
        bvpOptions
    end
    
    methods

        function obj=bvp2p(generateFodeFcn,generateBCFcn,options)
            arguments
                generateFodeFcn          function_handle
                generateBCFcn            function_handle
                options.bvpOptions        struct = []
                options.fcnForBvpOptions  = []
            end

            % Call abstractContProcedureProblem constructor
            obj=obj@abstractContProcedureProblem();

            % Check bvp options
            if  ~isempty(options.bvpOptions)
                obj.bvpOptions=options.bvpOptions;
                if ~isempty(options.fcnForBvpOptions)
                    error('fcnForBvpOptions and bvpOptions cannot be specified at the same time');
                end
                obj.fcnForBvpOptions=[];
            elseif ~isempty(options.fcnForBvpOptions)
                if ~isa(options.fcnForBvpOptions,'function_handle')
                    error('fcnForBvpOptions must a handle to a function');
                end
                obj.bvpOptions=[];
               
                obj.fcnForBvpOptions=options.fcnForBvpOptions;
            end

            % Store object values
            obj.generateFodeFcn=generateFodeFcn;
            obj.generateBCFcn=generateBCFcn;
        end
      

    end
     methods
        % Solve a problem for a given initial solution and parameters
        % values and manage the continuation procedure fields
        % (lastSolution, lastIterSuccess, lastMessage)
        obj=solveProblemContProcedure(obj,sol,params,fixedParams)
        
        % Solve a problem for the user
        % Do not update any fields
        sol=solveProblem(obj,sol,params,fixedParams)
    end

end