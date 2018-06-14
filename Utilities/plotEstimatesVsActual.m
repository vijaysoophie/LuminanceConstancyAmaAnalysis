function plotEstimatesVsActual(ConditionNumber,NImageInTrainingSet)
%plotEstimatesVsActual(ConditionNumber,NImageInTrainingSet)
%
% Example: plotEstimatesVsActual(1,900)
% 
% This function plots the actual v/s estimated luminance plot and the 
% filter response to the first two ama receptive fields.
% 
% Input:
%     ConditionNumber: Condition number to be analyzed (scalar)
%     NImageInTrainingSet: Number of images in the training set.
%
% Output: NONE
%   The figures are saved in the AmaAnalysis/results folder.
%
% VS wrote this Jun 14 2018
%

%%
% Get the output file
pathToOutputFile = fullfile(getpref('AmaAnalysis','outputBaseDir'), ...
    ['Condition',num2str(ConditionNumber)],['outputStruct_NTrainingSet',num2str(NImageInTrainingSet),'.mat']);

% load the files containing the estimates
outputStruct = load(pathToOutputFile);
outputStruct = outputStruct.outputStruct;

% Define the colors to be used for each method
lineStyles = linspecer(3);
linearColor = lineStyles(1,:);
AMAColor    = lineStyles(2,:);

for input = 1:2
    if input == 1
        % Get the Estimates
        numberOfCategories = length(unique(outputStruct.isomerization.AMA.ctgInd));
        NImagesPerCategory = size(outputStruct.isomerization.sTest,2)/numberOfCategories;
        meanLinearXest = mean(reshape(outputStruct.isomerization.linearTestEstimates,NImagesPerCategory,numberOfCategories));
        stdLinearXest = std(reshape(outputStruct.isomerization.linearTestEstimates,NImagesPerCategory,numberOfCategories));
        meanAMAXest = mean(reshape(outputStruct.isomerization.XEstimate(:,end),NImagesPerCategory,numberOfCategories));
        stdAMAXest = std(reshape(outputStruct.isomerization.XEstimate(:,end),NImagesPerCategory,numberOfCategories));
        actualLRV = outputStruct.isomerization.AMA.X;
        AMA = outputStruct.isomerization.AMA;
        linearTestEstimates = outputStruct.isomerization.linearTestEstimates;
        AMATestEstimates = outputStruct.isomerization.XEstimate(:,end);
        actualLRV2 = reshape(repmat(actualLRV,length(linearTestEstimates)/length(AMA.X),1),[],1);
        
    else
        numberOfCategories = length(unique(outputStruct.isomerization.AMA.ctgInd));
        NImagesPerCategory = size(outputStruct.contrast.sTest,2)/numberOfCategories;        
        meanLinearXest = mean(reshape(outputStruct.contrast.linearTestEstimates,NImagesPerCategory,numberOfCategories));
        stdLinearXest = std(reshape(outputStruct.contrast.linearTestEstimates,NImagesPerCategory,numberOfCategories));
        meanAMAXest = mean(reshape(outputStruct.contrast.XEstimate(:,end),NImagesPerCategory,numberOfCategories));
        stdAMAXest = std(reshape(outputStruct.contrast.XEstimate(:,end),NImagesPerCategory,numberOfCategories));
        actualLRV = outputStruct.contrast.AMA.X;
        AMA = outputStruct.contrast.AMA;
        linearTestEstimates = outputStruct.contrast.linearTestEstimates;
        AMATestEstimates = outputStruct.contrast.XEstimate(:,end);
        actualLRV2 = reshape(repmat(actualLRV,length(linearTestEstimates)/length(AMA.X),1),[],1);
        
    end
    % Plot the isomerization estimates
    fig = figure;
    set(fig,'units','pixels', 'Position', [1 1 500 500]);
    hold on;
    % plot the linear and svd response
    lDiagonal = plot([0.15 0.65],[0.15 0.65],'k:','linewidth',1);
    %         lNaive = plot(actualLRV,0.4*ones(size(actualLRV)),naiveColor,'linewidth',2);
    lLinear = plot(actualLRV,meanLinearXest,'Color',linearColor,'linewidth',2);
    
    xlim([0.15 0.65]);
    ylim([0.15 0.65]);
    xlabel('Actual target object LRV','FontSize',20);
    ylabel('Estimated target object LRV','FontSize',20);
    box on;
    set(gca,'FontSize',22)
    
    %% Plot the figures
    lAMA = plot(actualLRV,meanAMAXest,'Color',AMAColor,'linewidth',2);    
    axis square;
    plotfillederror(actualLRV, meanLinearXest-stdLinearXest,meanLinearXest+stdLinearXest,linearColor);
    plotfillederror(actualLRV, meanAMAXest-stdAMAXest,meanAMAXest+stdAMAXest,AMAColor);    
    legend([lLinear, lAMA],...
        {'Linear Model','AMA'}, 'Location','southeast','FontSize',20);
   
    pathToIsomerizationFolder = fullfile(getpref('AmaAnalysis','resultsBaseDir'),['Condition',num2str(ConditionNumber)],'isomerization');
    if (~exist(pathToIsomerizationFolder,'dir'))
        mkdir(pathToIsomerizationFolder);
    end
    pathToContrastFolder = fullfile(getpref('AmaAnalysis','resultsBaseDir'),['Condition',num2str(ConditionNumber)],'contrast');
    if (~exist(pathToContrastFolder,'dir'))
        mkdir(pathToContrastFolder);
    end

    if input == 1
        pathToResultsfile = fullfile(pathToIsomerizationFolder,'EstimatesVsActual.pdf');
        save2pdf(pathToResultsfile,gcf,600);
    else
        pathToResultsfile = fullfile(pathToContrastFolder,'EstimatesVsActual.pdf');
        save2pdf(pathToResultsfile,gcf,600);
    end
    close;
    % Plot the filter responses
    if input == 1
        plotFiltersJointResponsesModified(1,[1,2],actualLRV,outputStruct.isomerization.sTrain,AMA.f,AMA.ctgInd,[],[],[],[1:10]);        
        pathToResultsfile = fullfile(pathToIsomerizationFolder,'FilterResponse.pdf');
        save2pdf(pathToResultsfile,gcf,600);
    else
        plotFiltersJointResponsesModified(1,[1,2],actualLRV,outputStruct.contrast.sTrain,AMA.f,AMA.ctgInd,[],[],[],[1:10]);
        pathToResultsfile = fullfile(pathToContrastFolder,'FilterResponse.pdf');
        save2pdf(pathToResultsfile,gcf,600);
    end
	close;
    RMSELinear = sqrt(mean((1-linearTestEstimates./actualLRV2).^2));
    RMSEAMA = sqrt(mean((1-AMATestEstimates./actualLRV2).^2));
    
    if input == 1
        display(['Isomerization RMSE Linear = ',num2str(RMSELinear),' RMSE AMA = ',num2str(RMSEAMA)]);
    else
        display(['Contrast RMSE Linear = ',num2str(RMSELinear),' RMSE AMA = ',num2str(RMSEAMA)]);
    end
    
end