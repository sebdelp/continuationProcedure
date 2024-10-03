% Author: S. Delprat, UPHF, LAMIH UMR CNRS 8201
classdef logScheduler < abstractScheduler
    properties(SetAccess = private, GetAccess=public)
        lambdaMin
        delta
        deltaMin
        initialDelta
        beta
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
        function obj=logScheduler(paramStart,paramEnd,options)
            arguments
                paramStart                          struct
                paramEnd                            struct
                options.initialDelta                (1,1) double  {mustBePositive(options.initialDelta), mustBeLessThanOrEqual(options.initialDelta,1)}  = 0.8
                options.deltaMin                    (1,1) double  {mustBeNonnegative(options.deltaMin),mustBeLessThan(options.deltaMin,1)} = 0
                options.beta                        (1,1) double  {mustBeGreaterThan(options.beta,1)} = 1.05
                options.lambdaMin                   (1,1) double  {mustBePositive(options.lambdaMin),mustBeLessThan(options.lambdaMin,1)} = 1e-8
                options.doNotCheckParameterIsAFunction  (1,1) logical = false;
                options.fixedParams                     struct =  struct([])

            end
            
            % Call abstract scheduler initialization
            obj=obj@abstractScheduler(paramStart,paramEnd,...
                "doNotCheckParameterIsAFunction",options.doNotCheckParameterIsAFunction,...
                 "fixedParams",options.fixedParams);

            
            % store parameters
            obj.lambdaMin=options.lambdaMin;
            obj.initialDelta=options.initialDelta;
            obj.delta=options.initialDelta;
            obj.beta=options.beta;
            obj.deltaMin=options.deltaMin;
            obj.oldDelta=options.initialDelta;
            obj.stateFields={'delta','beta'};
        end

        function obj=reset(obj)
            % Implement the object reset
            obj=reset@abstractScheduler(obj);
            obj.delta=obj.initialDelta;
        end
    end % methods
end