% Author: S. Delprat, UPHF, LAMIH UMR CNRS 8201
classdef abstractScheduler < handle
    properties(SetAccess = private, GetAccess=public)
        paramsStart             = NaN
        paramsEnd               = NaN
        params                  = NaN
        fixedParams             = []
        lambda                   = 1;  % Continuation procedure parameter
    end
    properties( SetAccess = protected, GetAccess=public)
        currentIter = 1
    end
    properties(SetAccess = protected, GetAccess=public)
        lastLambdaSuccess               = 1;  % last value of lambda that lead to a feasible problem
        stop                            = false; % Indicates that the cont proc must be stopped as the pb is solved
        doNotCheckParameterIsAFunction  = false; % do not perform test
        stateFields                     = string([]); % List of fields that defines the scheduler state to be saved in the history          
    end

    methods(Abstract, Access={?continuationProcedure,?abstractScheduler})
        obj = updateIterResult(obj,iterResult) % update the value of the parameters according to the last success/fail 
        str = schedulerStateStr(obj)              % build a string with the current scheduler state
    end

    methods (Access=protected)
        % obj = updateParam(obj,lambda) % Update the current parameters values

    end
    methods (Access=public)

        function data=saveStateFields(obj,data)
            % This procedure save current state of the scheduler
            % data may be :
            % 1) a structure to be populated with stateFields (and their values)
            % 2) a structure with existing stateFields. Then new values are added at the end of the existing arrays 
            for i=1:length(obj.stateFields)
                if isfield(data,obj.stateFields{i})
                    data.(obj.stateFields{i})(end+1)=obj.(obj.stateFields{i});
                else
                    data.(obj.stateFields{i})=obj.(obj.stateFields{i});
                end
            end
        end
    end
    methods
        % Constructor
        function obj=abstractScheduler(paramsStart,paramsEnd,options)
        % Constructor
        % Input parameters (mandatory):
        % + paramStart  : structure with all the cont procedure parameters initial value
        % + paramEnd    : structure with all the cont procedure parameters final value
        % input parameters (optional name-value pairs)
        % + fixedParams : structure with all the fixed parameters
        % + doNotCheckParameterIsAFunction : allows by passing the test that prevents parameters names to also be a function name.
        arguments
                paramsStart  struct
                paramsEnd    struct
                options.doNotCheckParameterIsAFunction (1,1) logical = false;
                options.fixedParams  struct =  []
            end
    
          
          obj.doNotCheckParameterIsAFunction=options.doNotCheckParameterIsAFunction;

          if ~options.doNotCheckParameterIsAFunction
              checkParametersAreNotAlsoFunctions(obj,{paramsStart});
          end

          % Store object configuration
          obj.paramsStart    = paramsStart;
          obj.paramsEnd      = paramsEnd;
          obj.params         = paramsStart;
          obj.fixedParams    = options.fixedParams;
           
          % Check that fields are ok
          obj.checkFields(obj.paramsStart,obj.paramsEnd,'paramStart','paramEnd');
          obj.checkDuplicateFields(obj.paramsStart,obj.fixedParams,'paramStart','fixedParams');


        end

      

        % Other functions
    end
    
end
