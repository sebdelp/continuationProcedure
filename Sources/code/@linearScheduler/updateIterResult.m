function obj=updateIterResult(obj,iterSuccess)
arguments
    obj
    iterSuccess (1,1) logical  = true;
end

% backup step size value
obj.oldDelta=obj.delta;

if iterSuccess
    obj.lastDeltaSuccess=obj.delta;
    obj.lastLambdaSuccess=obj.lambda;

    % Optimistic increase of the step size
    obj.delta = obj.lastDeltaSuccess * obj.beta;
    obj.stop  = (obj.lastLambdaSuccess==obj.lambdaMin);
else
    obj.delta=max(obj.delta/obj.beta,obj.deltaMin);
    obj.stop=(obj.oldDelta==obj.deltaMin) && (obj.delta==obj.deltaMin);
end
lambda=max(obj.lambdaMin,obj.lastLambdaSuccess-obj.delta);
obj=obj.updateLambda(lambda);
obj.currentIter=obj.currentIter+1;
end