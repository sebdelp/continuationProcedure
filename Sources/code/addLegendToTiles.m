function addLegendToTiles(tiledLayoutObj,visibility)
% Switch legend to "show"
% Syntax: addLegendToTiles(tiledLayoutObj)
%           => add legend
% Syntax: addLegendToTiles(tiledLayoutObj,visibility)
%           => switch the legend visibility as specified
%           ('show','hide','toggle')
%
% Items with empty display names are not displayed in the legend


if nargin==1
    visibility='show';
end

tileHandles=findobj('parent',tiledLayoutObj,'type','axes');

for i=1:length(tileHandles)
    % Get all the plots with empty display name
    hPlotsToRemoveFromLegend=findobj(tileHandles(i),'type','Line','DisplayName','');
    for j=1:length(hPlotsToRemoveFromLegend)
        hPlotsToRemoveFromLegend(j).Annotation.LegendInformation.IconDisplayStyle='off';
    end
    % axes();
    legend(tileHandles(i),'show');
end

end