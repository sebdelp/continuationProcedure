function retrieveContinuationParameters(params)
% This function extract all the params fields into the caller workspace
% Author : S. Delprat, INSA Hauts-de-France, LAMIH UMR CNRS 8201
if ~iscell(params)
    param={params};
end

for noCell=1:length(params)
    param=params{noCell};
    if ~isempty(param)
        fields=fieldnames(param);
        for noField=1:length(fields)
            assignin('caller',fields{noField},param.(fields{noField}));
        end
    end
end

end