classdef OCPsteadyStateInitialization
    % This class implement the initialization of an optima control problem
    % It requires :
    % + a solver+problem (abstractContinuationProcedureProblem)
    % + a targetParam : typically the paramStart of the nex cont procedure 
    % + optionally fixed param
    % + stateFirst :  indicate wether state or costate is stored first in
    %    the BVP vector 
    properties (GetAccess=public,SetAccess=private)
        problem
        targetParams
        fixedParams
        stateFirst % If true then y=(x,p) otherwise y=(p,y)
        nState
        xss
        SolInit=[];
        Tf=NaN
        T0=NaN
        nInit=100;
    end
    properties (GetAccess=private,SetAccess=private)
        originalFode = [];
        originalBC   = [];
    end
    methods
        function obj=OCPsteadyStateInitialization(problem,xss,Tf,options)
            arguments
                problem abstractContProcedureProblem
                xss double
                Tf     (1,1) double = NaN;
                options.stateFirst (1,1) logical = true
                options.fixedParams struct =  [];
                options.targetParams struct = [];
                options.SolInit     struct = [];
                options.nInit (1,1) double = 10;
                options.T0     (1,1) double = NaN;
            end
            if size(xss,2)~=1
                error('xss must be a column vector');
            end
          

            % An initial solution was provided
            % => check consistency of T0 & Tf
            if ~isempty(options.SolInit)
                if (Tf~=options.SolInit.x(end))
                    error('The provided Tf value must match solInit data');
                end
                if  (T0~=options.SolInit.x(1)) && ~isnan(T0)
                    error('The provided T0 value must match solInit data');
                end
                options.T0=options.SolInit.x(1);
            end
            % Set default T0 value
            if isnan(options.T0)
                options.T0=0;
            end
            obj.xss=xss;
            obj.nState=length(xss);
            obj.Tf=Tf;
            % Store fields
            fields = fieldnames(options);
            for i=1:length(fields)
                obj.(fields{i})=options.(fields{i});
            end
            obj.problem=problem;

            % Store original function for later usage
            obj.originalFode=problem.generateFodeFcn(options.targetParams,options.fixedParams);
            obj.originalBC=problem.generateBCFcn(options.targetParams,options.fixedParams);

            % Create new generateFodeFcn and new generateBCFcn
        end

        function sol=run(obj)
            % This function tries to solve the problem from a trivial
            % solution using a continuation procedure

            % 1) find unique continutation procedure name :
            schedulingParamName=generateUniqueSchedulingParamName(obj);

            % 2) Add this variable to the cont proc parameters
            if isempty(obj.targetParams)
                schedulingParamName="kappa";
                paramStart.kappa = 0;
                paramEnd.kappa   = 1;
            else
                paramStart=obj.targetParams;paramEnd=obj.targetParams;
                paramStart.(schedulingParamName) = 0;
                paramEnd.(schedulingParamName) = 1;
            end

            % 3) Prepare continuation procedure problem
            if obj.stateFirst
                yss=[obj.xss;zeros(size(obj.xss))];
            else
                yss=[zeros(size(obj.xss));obj.xss];
            end
            problem=obj.problem;
            problem.generateFodeFcn = @(continuationParams,fixedParams) obj.generateFodeFcn(continuationParams,fixedParams,obj.originalFode,schedulingParamName,obj.xss,obj.stateFirst,obj.nState); 
            problem.generateBCFcn   = @(continuationParams,fixedParams) obj.generateBCFcn(continuationParams,fixedParams,obj.originalBC,schedulingParamName,obj.xss,obj.stateFirst,obj.nState); 
            
            % 4) Prepare a scheduler
            scheduler=linearScheduler(paramStart,paramEnd, fixedParams=obj.fixedParams,...
                initialDelta=0.1,beta=1.2,deltaMin=1e-10,lambdaMin=1e-10);

          
            
            % Initial solution
            if isempty(obj.SolInit)
                solInit.x=linspace(obj.T0,obj.Tf,obj.nInit);
                if obj.stateFirst
                    solInit.y=repmat([obj.xss;zeros(obj.nState,1)],[1 obj.nInit]);
                else
                    solInit.y=repmat([zeros(obj.nState,1);obj.xss],[1 obj.nInit]);
                end
            else
                solInit=obj.SolInit;
            end

            % Compute a solution
            cont=continuationProcedure(problem,scheduler,solInit, ...
                "doNotCheckInitialSol",true);
            cont.run;
            sol=cont.sol;

        end
    end
    methods(Access=private)
        function schedulingParamName=generateUniqueSchedulingParamName(obj)
            % Generate an arbitrary schedulingParamName
            fields={};
            if ~isempty(obj.targetParams)
                f=fieldnames(obj.targetParams);
                for i=1:length(f)
                    fields{end+1}=f{i};
                end
            end
            if ~isempty(obj.fixedParams)
                f=fieldnames(obj.fixedParams);
                for i=1:length(f)
                    fields{end+1}=f{i};
                end
            end
            % Generate a unique parameter name
            ended=false;no=0;
            while ~ended
                no=no+1;
                schedulingParamName="kappa"+string(no);
                ended=~strcmp(schedulingParamName,fields);
            end
        end
        function fcn=generateFodeFcn (obj,continuationParams,fixedParams,originalFode,schedulingParamName,xss,stateFirst,nState)
            % This function generates the BVP dynamics all along the
            % continuation procedure : dydt= [f*kappa;-dH/dx*kappa - 2*(1-kappa)*(x-xss)]
            % In Parameters
            % + continuationParams : targetParam, contains the problem values
            % + fixedParams       :  contains the problem values
            % + originalFode : BVP dynamics for the provided parameters
            % + schedulingParamName : name of the "kappa" parameter
            % + xss : target state value
            % + stateFirst if true y=[x,p] else y=[p,x]
            % + nState : number of state : length(y)= 2*nState
            % 
            % Out Parameters
            % + fcn: the BVP dynamics to be used wihtin the cont proc
            retrieveContinuationParameters({continuationParams,fixedParams});

            if stateFirst
                % Add the dynamics on the costate dynamics
                fcn= @(t,y) originalFode(t,y) * continuationParams.(schedulingParamName) + ...
                    (1-continuationParams.(schedulingParamName))* [zeros(nState,1);-2*(y(1:nState)-xss) ];
            else
                fcn= @(t,y) originalFode(t,y) * continuationParams.(schedulingParamName) + ...
                    (1-continuationParams.(schedulingParamName))* [-2*(y(nState+1:end)-xss);zeros(nState,1) ];
            end
        end

        function fcn=generateBCFcn (obj,continuationParams,fixedParams,originalBC,schedulingParamName,xss,stateFirst,nState)
            % This function generates the BVP dynamics all along the
            % continuation procedure : dydt= [f*kappa;-dH/dx*kappa - 2*(1-kappa)*(x-xss)]
            % In Parameters
            % + continuationParams : targetParam, contains the problem values
            % + fixedParams       :  contains the problem values
            % + originalFode : BVP dynamics for the provided parameters
            % + schedulingParamName : name of the "kappa" parameter
            % + xss : target state
            % + stateFirst if true y=[x,p] else y=[p,x]
            % + nState : number of state : length(y)= 2*nState
            % 
            % Out Parameters
            % + fcn: the BVP dynamics to be used wihtin the cont proc

            retrieveContinuationParameters({continuationParams,fixedParams});

            if stateFirst
            fcn=@(ya,yb)  originalBC(ya,yb)*continuationParams.(schedulingParamName) + ...
                    (1-continuationParams.(schedulingParamName))*[ya(1:nState)-xss;yb(1:nState)-xss];
            else
            fcn=@(ya,yb)  originalBC(ya,yb)*continuationParams.(schedulingParamName) + ...
                    (1-continuationParams.(schedulingParamName))*[ya(nState+1:end)-xss;yb(nState+1:end)-xss];
            end
        end
    end

end