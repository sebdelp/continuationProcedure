function postIterPrintFcn(algorithmState,continuationParams, fixedParam,BVPsolverMsg)
% Template for the postIterPrintFcn
% It is used to display information to user after the call to the BVP
% solver. BVPsolverMsg is the error message send by the solver (empty
% string is the bvp solver sucessfully solved the current bvp problem)

if ~algorithmState.iterSuccess
    fprintf('   => %s \n',BVPsolverMsg);
end

end