clearvars
close all
clc

% What is the proper way to uninstall a custom toolbox?
list=matlab.addons.installedAddons;

% Uninstall toolbox
idx = find(strcmp(list.Name, 'Continuation Procedure'));
if isempty(idx)
    error('toolbox not found')
end
fprintf('Uninstalling : %s\n',list.Name(idx));
toolboxToUninstall= table2struct((list(idx,:)));
name=list.Name(idx);
id=list.Identifier(idx);
matlab.addons.uninstall(id);
