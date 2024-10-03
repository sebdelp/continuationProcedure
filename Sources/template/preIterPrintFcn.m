function preIterPrintFcn(algorithmState, continuationParams, fixedParam)
% Template for the preIterPrintFcn
% It is used to display information to user before trying to solve the BVP
% problem of the current iteration
retrieveContinuationParameters({continuationParams,fixedParam});
fprintf('%s -Iter : %03i Lambda : %8.4e delta : %5.2e\n',algorithmState.strIter,algorithmState.noIter,algorithmState.lambda,algorithmState.delta);

% Add your code below to display information to the user
end