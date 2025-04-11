classdef bvp4or5c < abstractContProcedureProblem
    % Solve a boundary value problem usinbg bvp4c or bvp5c
    properties (SetAccess=private,GetAccess=public)
        fcnForBvpOptions
        bvpOptions
        catchMeshPointsError
        solValidationFcn 
    
    end
    properties (SetAccess= {?OCPsteadyStateInitialization}, GetAccess=public)
        generateFodeFcn
        generateBCFcn
    end
    properties (SetAccess=private, GetAccess=private)
        solverFcn
    end

   
    methods

        function obj=bvp4or5c(solver,generateFodeFcn,generateBCFcn,options)
            arguments
                solver                   (1,1) string {mustBeMember(solver,{'bvp4c','bvp5c'})}           
                generateFodeFcn          function_handle
                generateBCFcn            function_handle
                options.bvpOptions        struct = []
                options.fcnForBvpOptions  = []
                options.catchMeshPointsError (1,1) logical      = true
                options.solValidationFcn (1,1) function_handle = @defaultSolValidationFcn
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
            obj.catchMeshPointsError=options.catchMeshPointsError; % Force program to stop on error
            obj.solValidationFcn=options.solValidationFcn;

            switch solver
                case "bvp4c"
                    obj.solverFcn=@bvp4c;
                case "bvp5c"
                    obj.solverFcn=@bvp5c;
                
            end

        end
      
        
    end
    methods (Access=protected)
        % Solve a problem for a given initial solution and parameters
        % values and manage the continuation procedure fields
        % (lastSolution, lastIterSuccess, lastMessage)
        obj=solvePbContProcedure(obj,sol,params,fixedParams)
        sol=solvePb(obj,sol,params,fixedParams)

    end
end