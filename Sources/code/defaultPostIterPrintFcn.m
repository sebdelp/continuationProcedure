
function defaultPostIterPrintFcn(algorithmState,continuationParams, fixedParams,BVPsolverMsg)
if ~algorithmState.iterSuccess
    fprintf('   => %s \n',BVPsolverMsg);
end
end