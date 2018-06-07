function outputStruct = performAMAAnalysis(ConditionNumber, varargin)
%outputStruct = performAMAAnalysis('/Users/vijaysingh_local/Desktop/codesAndData/Color/analysisForPaper/data/Condition1/stimulusAMA.mat', 6);
%
% Uses: This function performs AMA analysis for a dataset given the 
%       condition number. We also perform the linear analysis.
% 
% Input: 
%     ConditionNumber: Condition number to be analyzed
%
%     nFilters : Number of filters that are required
%
% Output: 
%     outputStruct: Struct with the results. The struct contains the 
%           fields isomerization and contrast which give results for
%           isomerization and contrast based calculations. Each field
%           contains the following fields:
%           AMA : The AMA result struct
%           sTrain: Training set
%           sTest : Test set
%           lumTrain: Luminance level of the training set
%           lumTest: Luminance level of the test set
%           ctgIndTrain: Category index of the training set
%           ctgIndTest: Category index of the test set
%           XEstiamtes: Luminance estimates of the test set
%           error: estimated relative RMSE. error[i] gives the relative 
%                   RMSE calcuated using up to the i'th filter.
%           categorizationAccuracy: Accuracy of identification of the
%                   target object luminance level in the images.
%           linearTestEstimates: luminance estimates obtained using linear
%                   model on the center pixel.

%%
parser = inputParser();
parser.addParameter('nFilters', 6, @isnumeric);
parser.addParameter('nFSet', 1, @isnumeric);
parser.addParameter('fractionOfImagesInTrainingSet', 0.9, @isnumeric);

parser.parse(varargin{:});
nFilters = parser.Results.nFilters;
fractionOfImagesInTrainingSet = parser.Results.fractionOfImagesInTrainingSet;
nFSet = parser.Results.nFSet;

pathToFileIsomerizationFile = fullfile(getpref('AmaAnalysis','inputBaseDir'),['Condition',num2str(ConditionNumber)],'stimulusAMA.mat');
inputStruct = load(pathToFileIsomerizationFile);
data=inputStruct.allDemosaicResponse;
luminanceLevels = round(inputStruct.luminanceLevel*10000)/10000;

data = reshape(data,151,151,3,[]);
data = data(1:3:151,1:3:151,:,:);
data = reshape(data,[],size(data,4));

uniqueLuminanceLevels = unique(luminanceLevels);

% Get the isomerization data scaled by max value
isomerizationInput = data;
contrastInput = bsxfun(@rdivide,data,mean(data))-1;
contrastInput = normc(contrastInput);


for NTrainingSet = fractionOfImagesInTrainingSet*size(data,2)
    for input = 1:2
        if input == 1
            maxData = max(data(:));
            s = isomerizationInput;
        else
            maxData = 1;
            s = contrastInput;
        end
        
        % Divide into Train and test Set
         % Divide into Train and test Set
        trainIndex = [];
        for jj = 1 : length(uniqueLuminanceLevels)
            trainIndex = [trainIndex (1:NTrainingSet/10) + (size(data,2)/length(uniqueLuminanceLevels))*(jj-1)];
        end
        testIndex = [];
        for jj = 1:length(uniqueLuminanceLevels)
            testIndex = [testIndex (NTrainingSet/10+1:(size(data,2)/length(uniqueLuminanceLevels))) + ...
                (size(data,2)/length(uniqueLuminanceLevels))*(jj-1)];
        end
        sTrain = s(:,trainIndex(:));
        sTest = s(:,testIndex(:));
        
        lumTrain = luminanceLevels(trainIndex(:));
        lumTest = luminanceLevels(testIndex(:));
        
        %
        ctgIndTest = reshape(repmat((1:length(uniqueLuminanceLevels)),length(lumTest)/length(uniqueLuminanceLevels),1),[],1);
        ctgIndTrain = reshape(repmat((1:length(uniqueLuminanceLevels)),NTrainingSet/length(uniqueLuminanceLevels),1),[],1);
        
        %% Perform AMA
        scaleFactor = 1;
        rMax = 5.7;
        fano = 1.36/scaleFactor;  % 1.36
        var0 = 0.23/scaleFactor; % 0.23
        rndSd = 235423;
        btchSz = 150;
        nIterMax = 5;
        stpSzMax = 0.1;
        stpSzMin = 0.001;
        stpSzEta = 0.01;
        bGPU = 1;
        bUseGrd = 0;
        
        [f, E, minTimeSec, ~, ~, ~, AMA] = amaR01('SGD','MAP',nFilters,0,nFSet,[],sTrain/maxData, ...
            ctgIndTrain, unique(lumTrain), ...
            rMax,fano,var0,rndSd,btchSz,nIterMax,stpSzMax,stpSzMin,stpSzEta,bGPU,bUseGrd);
        
        %% Get Estimates
        
        for ii = 1 : nFilters
            [XHATi,PPi,CLi,Xi,MUi,COVi,SIGMAi,KAPPAi] = estimateXnew('gaussian',...
                unique(lumTrain),sTrain,AMA.f(:,1:ii),[],...
                ctgIndTrain,sTest,[],[],ctgIndTest,...
                1,5.7,0.23,'MAP','median','spline',8,[],0);
            error = sqrt(mean(((XHATi - lumTest')./lumTest').^2));
            differenceBetweenTwoCategories = mean(diff(unique(lumTrain)))/2;
            categorizationAccuracy = mean(abs(XHATi-lumTest')<differenceBetweenTwoCategories);
            XEstimate(:,ii) = XHATi;
            errorF(:,ii) = error;
            categorizationAccuracyF(:,ii) = categorizationAccuracy;
        end
        
        
        %% Perform Linear Analysis
        numberOfImagesInTrainingSet = size(sTrain,2);
        linearTrain = reshape(sTrain,51,51,3,numberOfImagesInTrainingSet);
        L = reshape(mean(mean(linearTrain(25:27,25:27,1,:),1),2),numberOfImagesInTrainingSet,1);
        M = reshape(mean(mean(linearTrain(25:27,25:27,2,:),1),2),numberOfImagesInTrainingSet,1);
        S = reshape(mean(mean(linearTrain(25:27,25:27,3,:),1),2),numberOfImagesInTrainingSet,1);
        
        numberOfImagesInTestSet = size(sTest,2);
        linearTest = reshape(sTest,51,51,3,numberOfImagesInTestSet);
        LTest = reshape(mean(mean(linearTest(25:27,25:27,1,:),1),2),numberOfImagesInTestSet,1);
        MTest = reshape(mean(mean(linearTest(25:27,25:27,2,:),1),2),numberOfImagesInTestSet,1);
        STest = reshape(mean(mean(linearTest(25:27,25:27,3,:),1),2),numberOfImagesInTestSet,1);
        
        linFitCoeffLum = ([L M S ones(size(L))]\lumTrain(:));
        linearTestEstimates = [LTest MTest STest ones(size(LTest))]*linFitCoeffLum;
        
        %% Save AMA Data
        if input == 1
            outputStruct.isomerization.maxData = maxData;
            outputStruct.isomerization.AMA = AMA;
            outputStruct.isomerization.sTrain = sTrain;
            outputStruct.isomerization.sTest = sTest;
            outputStruct.isomerization.lumTrain = lumTrain;
            outputStruct.isomerization.lumTest = lumTest;
            outputStruct.isomerization.ctgIndTrain = ctgIndTrain;
            outputStruct.isomerization.ctgIndTest = ctgIndTest;
            outputStruct.isomerization.XEstimate = XEstimate;
            outputStruct.isomerization.error = errorF;
            outputStruct.isomerization.categorizationAccuracy = categorizationAccuracyF;
            outputStruct.isomerization.linearTestEstimates = linearTestEstimates;
        else
            outputStruct.contrast.AMA = AMA;
            outputStruct.contrast.sTrain = sTrain;
            outputStruct.contrast.sTest = sTest;
            outputStruct.contrast.lumTrain = lumTrain;
            outputStruct.contrast.lumTest = lumTest;
            outputStruct.contrast.ctgIndTrain = ctgIndTrain;
            outputStruct.contrast.ctgIndTest = ctgIndTest;
            outputStruct.contrast.XEstimate = XEstimate;
            outputStruct.contrast.error = errorF;
            outputStruct.contrast.categorizationAccuracy = categorizationAccuracyF;
            outputStruct.contrast.linearTestEstimates = linearTestEstimates;
        end
        
    end
    
    %% Store the resulting struct
    pathToOutputFolder = getpref('AmaAnalysis','outputBaseDir');
    if (~exist(pathToOutputFolder))
        mkdir(pathToOutputFolder);
    end
    
    pathToOutputFile = fullfile(pathToOutputFolder,['outputStruct_NTrainingSet',num2str(NTrainingSet),'.mat']);
    save(pathToOutputFile,'outputStruct');
end
end
