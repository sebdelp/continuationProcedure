function [dataPlot,nextHandle]=myPlot(dataPlot,status,nextTileArgs,handleNo,varargin)
% Helper function that allows to plot & update (fast) by storing handle
% status=1 : init; status=2 : iter % status= 3 final
% status=4 : manual call from the code (perform init, iter &final)

% Process varargin
if strcmp(varargin{1},'log')
    plotFnc=@semilogy;
    varargin={varargin{2:end}};
else
    plotFnc=@plot;
end

if status==1 
    % Use plot to get a handle
    if ~iscell(nextTileArgs)
        nextTileArgs={nextTileArgs};
    end
    nexttile(nextTileArgs{:});
    if isempty(varargin{1})||isempty(varargin{2})
        varargin{1}=NaN;
        varargin{2}=NaN;
    end
    
    dataPlot.pltHandles(handleNo)=plotFnc(varargin{:});
    grid on;hold on;
else
    % Update data using handles
    set(dataPlot.pltHandles(handleNo),'XData',varargin{1},'YData',varargin{2});
end
nextHandle=handleNo+1;
end