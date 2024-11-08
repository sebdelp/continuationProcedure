classdef continuationProcedure < handle
    % This class implement a continuation procedure solver
    % It requires :
    % + a solver+problem (abstractContinuationProcedureProblem)
    % + a Scheduler (abstractScheduler)
    properties (GetAccess=public,SetAccess=public)
        ProblemSolver  
        Scheduler 
        SolInit = []
        strIter      (1,1) string = ""
        debug        (1,1) logical = false
        doNotCheckInitialSol (1,1) logical = false
        userStopFcn  (1,1) function_handle = @defaultUserStopFcn
        preIterPrintFcn (1,1) function_handle = @defaultPreIterPrintFcn
        postIterPrintFcn (1,1) function_handle = @defaultPostIterPrintFcn
        plotFigFcn   (1,1) function_handle = @emptyPlotFigFcn
        modifySolutionFcn (1,1) function_handle = @defaultModifySolutionFcn
        storeSolutionInHistory (1,1) logical = false
    end

    properties(GetAccess=public,SetAccess=private)
        isInitialized = false;
        history=[];
        sol=[];
        status=[]
        noIter=1;
        CPUcomputationTime=0;
        userStopRequest=false;
        wallTime double = 0
        result = [];
    end
    properties (Access=private)
        dataplot
        iterativeDisplay
    end

    properties(Access=private)
       startTime uint64 = 0 
    end
    methods
        % Constructor
        function obj=continuationProcedure(ProblemSolver,Scheduler,SolInit,options)
            arguments
                ProblemSolver abstractContProcedureProblem
                Scheduler abstractScheduler
                SolInit struct = []
                options.strIter      (1,1) string              = ""
                options.debug        (1,1) logical             = false
                options.doNotCheckInitialSol (1,1) logical     = false
                options.preIterPrintFcn (1,1) function_handle  = @defaultPreIterPrintFcn
                options.postIterPrintFcn (1,1) function_handle = @defaultPostIterPrintFcn
                options.userStopFcn  (1,1) function_handle     = @defaultUserStopFcn
                options.plotFigFcn   (1,1) function_handle     = @emptyPlotFigFcn
                options.modifySolutionFcn (1,1) function_handle = @defaultModifySolutionFcn
                options.storeSolutionInHistory (1,1) logical    = false

            end

            obj.ProblemSolver=ProblemSolver;
            obj.Scheduler=Scheduler;
            fields = fieldnames(options);
            for i=1:length(fields)
                obj.(fields{i})=options.(fields{i});
            end
            obj.isInitialized = false;
            obj.history=[];
            obj.dataplot=[];
            obj.status=0;
            obj.noIter=1;
            obj.SolInit=SolInit;
            obj.wallTime=0;
            obj.startTime=0;
            obj.result=[];

            % Create an iterative display object
            obj.iterativeDisplay=iterativeDisplay();
        end

        function obj=initialization(obj)
            % This function intialize the continuation procedure
            if isempty(obj.iterativeDisplay)
                obj.iterativeDisplay=iterativeDisplay();
            end
            
            % Start measuring time
            obj.startTime=tic;

            % Initialize the history to empty values
            obj.history.lambda=[];
            obj.history.iterSuccess=[];
            if obj.storeSolutionInHistory
                obj.history.solution={};
            end

            % Initialize the scheduler
            obj.Scheduler=obj.Scheduler.reset;

            % Eventually validate the initial solution
            if ~obj.doNotCheckInitialSol
                % Ensure that initial solution is feasible
                fprintf('Checking initial solution feasability\n')
            
                obj.ProblemSolver=obj.ProblemSolver.solveProblemContProcedure(obj.SolInit,obj.Scheduler.params,obj.Scheduler.fixedParams);
                
                if ~obj.ProblemSolver.lastIterSuccess
                    causeException = MException('continuationProcedure:SolInit','The provided initial solution is not feasible');
                    throw(causeException );
                end

                fprintf('Done (initial solution is feasible)\n')
                obj.sol=obj.ProblemSolver.lastSolution;

                % Modify solution if needed
                obj.sol=obj.modifySolutionFcn(obj.sol,true,obj.Scheduler.params,obj.Scheduler.fixedParams);

                % Update history
                obj.history.lambda(end+1)=obj.Scheduler.lambda;
                obj.history.iterSuccess(end+1)=obj.ProblemSolver.lastIterSuccess;
                obj.history=obj.Scheduler.saveStateFields(obj.history);
                obj.history.params=obj.Scheduler.params;

                if obj.storeSolutionInHistory
                    obj.history.solution{end+1}=obj.sol;
                end
            else
                % Initial solution is not computed : use initial sol
                fprintf('Initial solution is supposed feasible\n')
                obj.sol=obj.SolInit;

                % Precompute
                obj.sol=obj.modifySolutionFcn(obj.sol,true,obj.Scheduler.params,obj.Scheduler.fixedParams);

                obj.history.lambda(end+1)=obj.Scheduler.lambda;
                obj.history.iterSuccess(end+1)=NaN; % Assumed
                obj.history=obj.Scheduler.saveStateFields(obj.history);
                obj.history.params=obj.Scheduler.params;
                if obj.storeSolutionInHistory
                    obj.history.solution{end+1}=obj.sol;
                end
            end


            % Initialisation of plots, if needed
            if ~isempty(obj.plotFigFcn)
                if  obj.debug
                    fprintf('Initialization of the plot function\n ')
                end

                obj.status=1; % Init
                obj.dataplot.history=obj.history;
                obj.iterativeDisplay.newIteration;
                obj.dataplot=obj.plotFigFcn(obj.dataplot,obj.status,obj.iterativeDisplay,obj.sol,obj.Scheduler.params,obj.Scheduler.fixedParams,sprintf('%02i - \\lambda=%.2e',0,obj.Scheduler.lambda));
                obj.status=2; % Running
            end

            % Take a step assuming that the first solution is a sucess
            obj.Scheduler.updateIterResult(true);


            obj.CPUcomputationTime=0;
            obj.userStopRequest=false;
            obj.isInitialized=true;
        end


        function obj=takeStep(obj)
            % This function performs one step of the continuation procedure
            if ~obj.isInitialized
                error('ContinuationProcedure:The continuation procedure is not initialized. You must call "vinitialization" before "TakeStep"');
            end
            % Pré-iteration display
            clear algorithmState;
            obj.status=2; % Running

            algorithmState.currentSol=obj.sol;
            algorithmState.noIter=obj.noIter;
            algorithmState.strIter=obj.strIter;
            algorithmState.lambda=obj.Scheduler.lambda;

            algorithmState.iterSuccess=NaN; % Not available yet
            algorithmState=obj.Scheduler.saveStateFields(algorithmState);
            algorithmState.schedulerStateStr=obj.Scheduler.schedulerStateStr();
            obj.preIterPrintFcn(algorithmState,obj.Scheduler.params, obj.Scheduler.fixedParams);

            % Compute solution & measure time
            initialComputationClock=cputime;
            obj.ProblemSolver=obj.ProblemSolver.solveProblemContProcedure(obj.sol,obj.Scheduler.params,obj.Scheduler.fixedParams);
            finalComputationClock=cputime;
            tStart=tic;
            if obj.ProblemSolver.lastIterSuccess
                % problem was sucessfully solved, update current solution
                obj.sol=obj.ProblemSolver.lastSolution;
            end
            obj.CPUcomputationTime=obj.CPUcomputationTime+finalComputationClock-initialComputationClock;
            obj.wallTime=obj.wallTime+toc(tStart);
            % Now we know if this iteration was or not a success

            % Modify solution if needed
            obj.sol=obj.modifySolutionFcn(obj.sol,obj.ProblemSolver.lastIterSuccess,obj.Scheduler.params,obj.Scheduler.fixedParams);

            % Update history
            obj.history.lambda(end+1)=obj.Scheduler.lambda;
            obj.history.iterSuccess(end+1)=obj.ProblemSolver.lastIterSuccess;
            obj.history.params(end+1)=obj.Scheduler.params;

            obj.history=obj.Scheduler.saveStateFields(obj.history);
            if obj.storeSolutionInHistory
                obj.history.solution{end+1}=obj.sol;
            end
        
            
            % Post iter display
            clear algorithmState;
            % algorithmState.delta=options.delta;
            % algorithmState.lambda=lambda;
            algorithmState.currentSol=obj.sol;
            algorithmState.lambda=obj.Scheduler.lambda;

            algorithmState.noIter=obj.noIter;
            algorithmState.strIter=obj.strIter;
            algorithmState.iterSuccess=obj.ProblemSolver.lastIterSuccess;
            algorithmState=obj.Scheduler.saveStateFields(algorithmState);
            algorithmState.schedulerStateStr=obj.Scheduler.schedulerStateStr();
            
            
            % Display info to the user
            obj.postIterPrintFcn(algorithmState,obj.Scheduler.params, obj.Scheduler.fixedParams,obj.ProblemSolver.lastMessage);

            % User stop function
            obj.userStopRequest=obj.userStopFcn(algorithmState,obj.Scheduler.params, obj.Scheduler.fixedParams,obj.ProblemSolver.lastMessage);

            % Display solution
            if ~isempty(obj.plotFigFcn)
                obj.iterativeDisplay.newIteration;
                obj.dataplot.history=obj.history;
                obj.dataplot=obj.plotFigFcn(obj.dataplot,obj.status,obj.iterativeDisplay,obj.sol,obj.Scheduler.params,obj.Scheduler.fixedParams,sprintf('%02i - \\lambda=%.2e',obj.noIter,obj.Scheduler.lambda));
            end

            % Next iter of the continuation procedure
            obj.Scheduler.updateIterResult(obj.ProblemSolver.lastIterSuccess);
            obj.noIter=obj.noIter+1;
        end

        function obj=run(obj)
            % This function runs the continuation procedure until the a
            % stop is requested either by the scheduler or the optional,
            % user-supplied, userStopRequest function.
            obj=obj.initialization();
            while ~obj.userStopRequest && ~obj.Scheduler.stop
                takeStep(obj);
            end
            
            % Display last valid iteration
            if ~isempty(obj.plotFigFcn) && (obj.ProblemSolver.lastIterSuccess || obj.userStopRequest)
                obj.status=3; % Final plot

                obj.iterativeDisplay.finalIteration;
                obj.dataplot.history=obj.history;
                obj.dataplot=obj.plotFigFcn(obj.dataplot,obj.status,obj.iterativeDisplay,obj.sol,obj.Scheduler.params, ...
                                            obj.Scheduler.fixedParams,sprintf('%02i - \\lambda=%.2e',obj.noIter,obj.Scheduler.lambda));
            end
            % Provide feedback to the user
            obj.result=[];
            if obj.userStopRequest
                obj.result.msg='Continuation procedure stopped by user stop function';
                obj.result.sucess=false;
            elseif obj.ProblemSolver.lastIterSuccess
                obj.result.msg='Solution found by the continuation procedure';
                obj.result.sucess=true;
            else
                obj.result.msg=obj.ProblemSolver.lastMessage;
                obj.result.sucess=false;
            end

            % Delete iterative display
            obj.iterativeDisplay=[];
        end
        
    end

    
end