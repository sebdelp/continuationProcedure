clearvars
close all
clc

% Time
fullInFilename='createStructureFromVariable.mlx';
fileOutFilename='createStructureFromVariable.html';
% export(fullInFilename,fileOutFilename,'Run',false);
f=@() export(fullInFilename,fileOutFilename,'Run',false);


duration=timeit(f);
fprintf('Elapsed time : %.2f seconds\n',duration);
