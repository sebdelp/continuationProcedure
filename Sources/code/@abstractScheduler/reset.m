function obj=reset(obj)
% Reset the object to its initial state
obj.lambda=1;
obj.params=obj.paramsStart;
obj.currentIter=1;
obj.stop=false;
obj.lastLambdaSuccess=1;
end