function plotFiltersColor2D(f,fSmp,overallTitle,bsmoothing)
%plotFiltersColor2D(f,fSmp,overallTitle,bsmoothing)
%
%   example call: plotFiltersColor2D(f,[],[],1)
%
% Uses: This function plot two filters given in the matrix f.
%
% Input:
% f:          filter weights
% fSmp:       values at which filter weights are sampled
% figh:       figure handle
% bsmoothing: boolean to specify linear interpolation for smooth figures
%
% Output: None
% A plot is generated on the screen.

if ~exist('fSmp','var') || isempty(fSmp) fSmp = [0:(size(f,1)/2-1)]; fSmp = fSmp-max(fSmp)/2-1;  end

% HANDLE FIGURE
figh = figure;
set(gcf,'position',[991 973 500 300]);

% PLOT
for i = 1:size(f,2)
    % SUBPLOT ORGANIZATION: <= 3 plot each row, 1 row for each filter
    if ~bsmoothing        
        fSmooth = zeros(size(f,1),size(f,2));
        fSmooth(:,i) = f(:,i);
    else
        sizeOfGrid = sqrt(size(f,1)/3);
        [X,Y] = meshgrid((1:sizeOfGrid),(1:sizeOfGrid));
        [XX,YY] = meshgrid((1:0.25:sizeOfGrid),(1:0.25:sizeOfGrid));
        fSmooth = zeros(length(XX(:)),size(f,2));
        for kk = 1:3
            fSmooth((kk-1)*length(XX(:))+1:kk*length(XX(:)),i) = ...
                griddata(X(:),Y(:),f((kk-1)*length(X(:))+1:kk*length(X(:)),i),XX(:),YY(:));
        end
    end
    fSqr = reshape(fSmooth(:,i),[sqrt(size(fSmooth,1)/3) sqrt(size(fSmooth,1)/3) 3]); 
    for j = 1:3, 
%         subplot(size(fSmooth,2),3,(i-1)*3+j);
        if (j<3)
            if i == 1
                axes(figh,'units','pixels','position',[(j-1)*120+60 180 100 100]);
            else
                axes(figh,'units','pixels','position',[(j-1)*120+60 40 100 100]);
            end
        else
            if i == 1
                axes(figh,'units','pixels','position',[(j-1)*120+60 180 150 100]);
            else
                axes(figh,'units','pixels','position',[(j-1)*120+60 40 150 100]);
            end
        end
        imagesc(fSqr(:,:,j));
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        axis square;
        
        colormap(cmapBWR);
        caxis([-.04 .04]); colormap(cmapBWR);    
        if (i==1 & j==3) colorbar; set(gca,'Fontsize',15); end
        if (i==2 & j==3) colorbar; set(gca,'Fontsize',15); end

        switch j
            case 1
                channelName = ' L';
            case 2
                channelName = ' M';
            case 3
                channelName = ' S';
        end
            xlabel([num2str(i),channelName],'FontSize',20);
        if (i==1 & j==2) title(overallTitle,'FontSize',20); end        
        
    end
end
    