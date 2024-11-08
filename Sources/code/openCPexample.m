function openCPexample(no)
exampleList={"toyProblem","stateConstraint","user_regularizationByPerturbation",...
    "regularization_GRCO","user_OCPinitialization","goddard","benchmarkSolver"};
if no>length(exampleList)
    error('Invalid example number. Valid numbers are 1..%i',length(exampleList));
end
file=exampleList{no};
if ~isstring(file)
    file=string(file);
end
inFile=which("user_"+ file +".mlx");
outFile=fullfile(pwd,file +".mlx");
copyfile(inFile,outFile);
open(outFile);
end