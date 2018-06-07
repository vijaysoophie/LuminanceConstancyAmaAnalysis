function plotReceptiveFields(ConditionNumber,NImageInTrainingSet)

% Get the output file
pathToOutputFile = fullfile(getpref('AmaAnalysis','outputBaseDir'), ...
    ['Condition',num2str(ConditionNumber)],['outputStruct_NTrainingSet',num2str(NImageInTrainingSet),'.mat']);

% load the files containing the estimates
outputStruct = load(pathToOutputFile);
outputStruct = outputStruct.outputStruct;

pathToIsomerizationFolder = fullfile(getpref('AmaAnalysis','resultsBaseDir'),['Condition',num2str(ConditionNumber)],'isomerization');
if (~exist(pathToIsomerizationFolder,'dir'))
    mkdir(pathToIsomerizationFolder);
end
pathToContrastFolder = fullfile(getpref('AmaAnalysis','resultsBaseDir'),['Condition',num2str(ConditionNumber)],'contrast');
if (~exist(pathToContrastFolder,'dir'))
    mkdir(pathToContrastFolder);
end

for input = 1:2
    if input == 1
        plotFiltersColor2D(outputStruct.isomerization.AMA.f(:,1:2),[],[],1);
        pathToResultsfile = fullfile(pathToIsomerizationFolder,'ReceptiveFields.pdf');
        save2pdf(pathToResultsfile,gcf,600);
    else
        plotFiltersColor2D(outputStruct.contrast.AMA.f(:,1:2),[],[],1);
        pathToResultsfile = fullfile(pathToContrastFolder,'ReceptiveFields.pdf');
        save2pdf(pathToResultsfile,gcf,600);
    end
end