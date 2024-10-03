function str = schedulerStateStr(obj)
str=sprintf('Iter : %03i Lambda : %8.4e delta : %5.2e',obj.currentIter,obj.lambda,obj.delta);
end