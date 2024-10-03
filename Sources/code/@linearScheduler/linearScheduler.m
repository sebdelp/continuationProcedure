% Author: S. Delprat, UPHF, LAMIH UMR CNRS 8201
classdef linearScheduler < abstractScheduler
    properties(SetAccess = private, GetAccess=public)
        lambdaMin
        delta
        deltaMin
        beta
        initialDelta
    end

    properties(SetAccess = private, GetAccess=private)
        oldDelta
        lastDeltaSuccess
    end
    methods (Access={?continuationProcedure,?abstractScheduler})
             % Other methods
        obj=updateIterResult(obj,iterSuccess)
        str = schedulerStateStr(obj)
    end
    methods
        % Constructor
        function obj=linearScheduler(paramStart,paramEnd,options)
            arguments
                paramStart                          struct
                paramEnd                            struct
                options.initialDelta                (1,1) double  {mustBePositive(options.initialDelta), mustBeLessThanOrEqual(options.initialDelta,1)}  = 0.1
                options.deltaMin                    (1,1) double  {mustBeNonnegative(options.deltaMin)} = 0
                options.beta                        (1,1) double  {mustBeGreaterThanOrEqual(options.beta,1)} = 1.05
                options.lambdaMin                   (1,1) double  {mustBeNonnegative(options.lambdaMin),mustBeLessThan(options.lambdaMin,1)} = 0
                options.doNotCheckParameterIsAFunction  (1,1) logical = false;
                options.fixedParams struct =  []
            end
            
            % Call abstract scheduler initialization
            obj=obj@abstractScheduler(paramStart,paramEnd,...
                "doNotCheckParameterIsAFunction",options.doNotCheckParameterIsAFunction,...
                "fixedParams",options.fixedParams);

            % Check delta value
            if options.initialDelta>=1
                error('LinearScheduler: options.initialDelta must be stricly positive and strictly lower than 1.');
            end

           
            % store parameters
            obj.lambdaMin=options.lambdaMin;
            obj.initialDelta=options.initialDelta;

            obj.delta=options.initialDelta;
            obj.beta=options.beta;
            obj.deltaMin  =options.deltaMin;
            obj.stateFields={'delta','beta'};
        end

    function obj=reset(obj)
        % Implement the object reset
        obj=reset@abstractScheduler(obj);
        obj.delta=obj.initialDelta;
    end
    end % methods
end