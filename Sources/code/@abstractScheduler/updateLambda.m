function obj=updateLambda(obj,lambda)
% This function update the parameters according to lambda
% Set lambda: prevent lambda from being negative
arguments
    obj
    lambda (1,1) double {mustBeNonnegative(lambda)}
end
obj.lambda=lambda;
fields=fieldnames(obj.paramsStart);
for i=1:length(fields)
    obj.params.(fields{i})=lambda*(obj.paramsStart.(fields{i})-obj.paramsEnd.(fields{i})) + obj.paramsEnd.(fields{i});
end
end