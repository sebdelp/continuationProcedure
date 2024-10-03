function plotHistory(dataPlot,id,lambdaPlotScale)
% This function plot the history of the continuation procedure
arguments
    dataPlot
    id iterativeDisplay
    lambdaPlotScale string {mustBeMember(lambdaPlotScale,{'lin','log'})} = "lin"
end

if isempty(dataPlot.history.lambda)
    % Initialization with dummy variables
    xLambdaSuccess=0;yLambdaSuccess=0;
    xLambdaFail=0;yLambdaFail=0;
    allX=0;allY=0;
else
    allX=1:length(dataPlot.history.lambda);
    allY=dataPlot.history.lambda;
    iSuccess=dataPlot.history.iterSuccess;
    
    xLambdaSuccess=allX(iSuccess);
    yLambdaSuccess=dataPlot.history.lambda(iSuccess);
    xLambdaFail=allX(~iSuccess);
    yLambdaFail=dataPlot.history.lambda(~iSuccess);
end

% if strcmpi(dataPlot.history.schedule,'log')
if lambdaPlotScale=="log"
    % Use log schedule
    id.semilogy(allX,allY,'-');
    id.hold('on');
    id.semilogy(xLambdaSuccess,yLambdaSuccess,'*');
    id.semilogy(xLambdaFail,yLambdaFail,'*');
    id.legend('\lambda');
    id.xlabel('Iteration');
else
    % Use linear schedule
    id.plot(allX,allY,'-');
    id.hold('on');
    id.plot(xLambdaSuccess,yLambdaSuccess,'*');
    id.plot(xLambdaFail,yLambdaFail,'*');
    id.legend('\lambda');
    id.xlabel('Iteration');
end
end