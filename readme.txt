Welcome to AMA analysis.

Our publication "Computational luminance constancy from naturalistic images" is available at: https://doi.org/10.1167/18.13.19

To cite this work: Vijay Singh, Nicolas P. Cottaris, Benjamin S. Heasly, David H. Brainard, Johannes Burge; Computational luminance constancy from naturalistic images. Journal of Vision 2018;18(13):19. https://doi.org/10.1167/18.13.19.

We believe you know about Virtual world color constancy (VWCC).
To learn about VWCC, go here:
https://github.com/BrainardLab/VirtualWorldColorConstancy

We also believe you know about ToolboxToolbox: 
https://github.com/ToolboxHub/ToolboxToolbox

This document describes the steps to analyze data in the publication mentioned above.

1. Download the repository LuminanceConstancyAmaAnalysis and put it in your projects folder.

2. Go to the configuration file LuminanceConstancyAmaAnalysisLocalHookTemplate and set up 
the configuration for your computer as you like. The part that you need to 
modify are in line 31-53. If not modified, the paths are chosen as per 
Brainard lab conventions.

3. In matlab do: 
tbUseProject('LuminanceConstancyAmaAnalysis','reset','full');

4. To run the AMA analysis for condition 1 do:
performAMAAnalysis(1,'bGPU',false);

This would perform the analysis on Condition 1. 
The defaults condition will learn 6 filters in sets of 1 filter (greedy algorithm).
To learn about the parameters see documentation of performAMAAnalysis.
The output will be saved in LuminanceConstancyAmaAnalysis/outputs in the folder Condition1.

5. Visualize results of the analysis.
    a. To visualize the first two AMA filters, do 
        plotReceptiveFields(1,900)

    Inputs:
    The first input parameter is the condition number.
    The second input parameter is the number of images used in training set.

    Output:
    Figure will be saved in LuminanceConstancyAmaAnalysis/results in the folder Condition 1

    b. To visualize the filter response and compare the estimated luminance 
        v/s actual luminance, do:
    
    plotEstimatesVsActual(1,900);    

    Output:
    Figure will be saved in LuminanceConstancyAmaAnalysis/results in the folder Condition 1

    %%% NOTE FOR CONDITION 3 %%%

    For condition 3, there are 3000 total images in the dataset. 
    The default setting will use 2700 images for AMA analysis and the 
    output will be named accordingly as outputStruct_NTrainingSet2700.
    So in step 6, the corresponding commands need to be modified to:
    plotReceptiveFields(1,2700)
    plotEstimatesVsActual(1,2700)

    %%%% %%%%


Questions: vsin@sas.upenn.edu

