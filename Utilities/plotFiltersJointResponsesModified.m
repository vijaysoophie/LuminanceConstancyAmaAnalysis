function plotFiltersJointResponsesModified(bPltRsp,fPairs,X,sTrn,fTrn,ctgIndTrn,sTst,fTst,ctgIndTst,ctg2plt,rMax,fano,var0,axisLims,bPLOTellipse)

% function plotFiltersJointResponses(bPltRsp,fPairs,X,sTrn,fTrn,ctgIndTrn,sTst,fTst,ctgIndTst,ctg2plt,rMax,fano,var0,axisLims,bPLOTellipse)
%
%   example call: plotFiltersJointResponses(1,[1 2; 3 4],X,s,f,ctgInd)
%
% plot joint filter responses for specified filter pairs
%
% bPltRsp:      boolean indicating whether to scatter plot responses or not
%               1 -> scatter plot responses
%               0 -> don't (plots only rsp ellipses)
% fPairs:       filter pairs to plot                 [ nPairs  x    2    ]
% X:            category values                      [ 1       x  nCtg   ]
% sTrn:         stimuli           (training set)     [ d       x nStmTrn ]
% fTrn:         filters           (training set)     [ d       x    q    ]
% ctgIndTrn:    category indices  (training set)     [ nStmTrn x    1    ]
%               having nCtg unique values
% sTst:         stimuli           (  test   set)     [ d       x nStmTst ]
%               default = sTrn
% fTst:         filters           (  test   set)     [ d       x    q    ] 
%               default = fTrn
% ctgIndTst:    category indices  (  test   set)     [ nStmTst x    1    ]
%               default = ctgIndTrn
% rMax:         response max
% fano:         response fano factor
% var0:         response baseline variance
% axisLims:     manual control over axis limits (e.g. rMax*[-1 1 -1 1])
% bPLOTellipse: plot ellipse or not
%               1 -> plot 
%               0 -> not

% INPUT HANDLING
if ~exist('sTst',        'var') || isempty(sTst)         sTst      = sTrn;              end
if ~exist('fTst',        'var') || isempty(fTst)         fTst      = fTrn;              end
if ~exist('ctgIndTst',   'var') || isempty(ctgIndTst)    ctgIndTst = ctgIndTrn;         end
if ~exist('ctg2plt'  ,   'var') || isempty(ctg2plt)      ctg2plt   = unique(ctgIndTst); end
if ~exist('rMax',        'var') || isempty(rMax)         rMax      = 1;                 end
if ~exist('fano',        'var') || isempty(fano)         fano      = 0;                 end
if ~exist('var0',        'var') || isempty(var0)         var0      = 0;                 end
if ~exist('X',           'var') || isempty(X)            X = unique(ctgIndTst);         end
if ~exist('bPLOTellipse','var') || isempty(bPLOTellipse) bPLOTellipse = 1;         end

% COMPUTE FILTER RESPONSES TO TRAINING AND TEST STIMS
rTrn   = stim2resp(sTrn,fTrn,rMax);
rTst   = stim2resp(sTst,fTst,rMax);

% MLE FIT CONDITIONAL RESPONSE DISTIRBUTIONS
modelCR = 'gaussian';
[MU,COV,SIGMA,KAPPA] = fitCondRespDistribution(modelCR,sTrn,fTrn,rTrn,ctgIndTrn,rMax);

% PLOT FILTER RESPONSES
figure('position',[493   281   500   500]); 

% SET COLORDER
colors = getColorOrder([],2.*length(X));
legendIndicator = [];
legendName = {};

for t = 1:size(fPairs,1)
    hold on; subplot(1,ceil(size(fPairs,1)),t); hold on
    % AXIS LIMS
    if ~exist('axisLims','var') || isempty(axisLims), if t == 1, axisLims = 1.2.*max(max(abs(rTrn(:,fPairs(t,:))))).*[-1 1 -1 1]; end; end
    % PLOT CONDITIONAL DISTRIBUTIONS
    for c = 1:1:length(ctg2plt),
        % INDICES IN CURRENT CATEGORY
        ind = find(ctgIndTst==ctg2plt(c)); % & sqrt(sum(rTst(:,1:2).^2,2)) < 0.2);
        % PLOT ELLIPSE
        if bPLOTellipse
            h(c) = plotEllipse(MU(ctg2plt(c),:),COV(:,:,ctg2plt(c)),90,fPairs(t,:),2,colors(ctg2plt(c),:));
            legendIndicator(c) = h(c);
            legendName{c} = num2str(X(c),2);
        end
        % SCATTER PLOT RESPONSES
        if bPltRsp, 
            if c ==1 || c>1 % 
            % if  c==1 || X(ctg2plt(c)) == 0 %  
            indRnd  = randsample(1:length(ind),min([1000 numel(ind)])); 
            % PLOT DATA POINTS
            if bPLOTellipse==0
                h(c)=plot(rTst(ind(indRnd),fPairs(t,1)),rTst(ind(indRnd),fPairs(t,2)),'wo','linewidth',.125,'markerface',colors(ctg2plt(c),:),'markersize',6); 
            else
                plot(rTst(ind(indRnd),fPairs(t,1)),rTst(ind(indRnd),fPairs(t,2)),'wo','linewidth',.125,'markerface',colors(ctg2plt(c),:),'markersize',6); 
            end
            
%             % PLOT MARGINAL CATEGORY-CONDITIONED MARGINAL
%             [H1,B1]=hist(rTst(ind(indRnd),fPairs(t,1)),linspace(axisLims(1),axisLims(2),31));
%             [H2,B2]=hist(rTst(ind(indRnd),fPairs(t,2)),linspace(axisLims(1),axisLims(2),31));
%             plot(B1,0.1.*diff(axisLims(1:2)).*H1./max(H1) + axisLims(1),'color',colors(ctg2plt(c),:),'linewidth',1.5);
%             plot(0.1.*diff(axisLims(1:2)).*H2./max(H2) + axisLims(1),B2,'color',colors(ctg2plt(c),:),'linewidth',1.5);
            end
        end
%         if c == length(ctg2plt)
%             [H1,B1]=hist(rTst(:,fPairs(t,1)),linspace(axisLims(1),axisLims(2),31));
%             [H2,B2]=hist(rTst(:,fPairs(t,2)),linspace(axisLims(1),axisLims(2),31));
%             plot(B1,0.2.*diff(axisLims(1:2)).*H1./max(H1) + axisLims(1),'k');
%             plot(0.2.*diff(axisLims(1:2)).*H2./max(H2) + axisLims(1),B2,'k');
%         end
        % MAKE PRETTY
        formatFigure(['RF' num2str(fPairs(t,1)) ' response'],['RF' num2str(fPairs(t,2)) ' response']);
        % SET AXIS LIMS
        axis([1.1*min(rTrn(:,1)) 1.1*max(rTrn(:,1)) 1.1*min(rTrn(:,2)) 1.1*max(rTrn(:,2))]); 
        axis square;
        pause(.5);
    end;
end
set(gca,'FontSize',22)
xlabel(['RF' num2str(fPairs(t,1)) ' response'],'FontSize',26);
ylabel(['RF' num2str(fPairs(t,2)) ' response'],'FontSize',26);
legend(legendIndicator,legendName,'Location','southwest','FontSize',18);

% try   legend(h,legendLabel('Y = ', X(ctg2plt),1,4),'Location','NorthEast');
% catch legend(legendLabel('X=',X(ctg2plt),1,4),'Location','NorthEast');
% end