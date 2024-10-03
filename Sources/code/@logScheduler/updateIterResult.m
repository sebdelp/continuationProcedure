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

    % Optimistic increase of delta
    obj.delta=max(obj.lastDeltaSuccess/obj.beta,obj.deltaMin);
    obj.stop      = obj.lastLambdaSuccess<=obj.lambdaMin;
else
    obj.delta=1-(obj.lastLambdaSuccess-obj.lambda)/obj.lastLambdaSuccess*(1-1/obj.beta);
    obj.stop=(1-obj.oldDelta<=obj.deltaMin) && (1-obj.delta<=obj.deltaMin);
end
lambda=obj.lastLambdaSuccess*obj.delta;
obj.updateLambda(lambda);
obj.currentIter=obj.currentIter+1;
end