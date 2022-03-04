clc;clear;close all;
%% data information
% s: event time points 
%        data length x conditions
% procResult.dc: Hb concentrations
%        data length x Hb components (HbO, HbR,Hbtotal) x channels
% procResult.dcAvg: block averages of Hb
%        block length x Hb components x channels x conditions
% SD.MeasListAct: Enable/Disable channels
% tIncMan: Manually excluded time interval
clear;clc; close all
%% parameter initialization
channelnum=20;
samplerate = 7.61; % in Hz
sclConc = 1e6; % convert Conc from Molar to uMolar
blockint=[-5 30]; % block interval in second, please include baseline period(epoch)
interval1=[5 20]; % the interval for evaluating mean values in second(mean)
blockind=[round(blockint(1)*samplerate):round(blockint(2)*samplerate)];
baseind=find(blockind<0);
%% load *.nirs files within the folder
datadir=uigetdir('Please pick up a folder of HOMER2 data');
dirinfo=dir(datadir);
dirinfo(1:2)=[];

MeasListAct=[];
AvgHbmat_HbO=[];  %{iCon} trials * channels 
AvgHbmat_HbR=[];  %{iCon} trials * channels
for subdat=1:length(dirinfo)
    singdat=[]
    load([datadir filesep dirinfo(subdat).name],'-mat')
   % tHRF = procResult.tHRF;
    singdat = procResult.dc;% timepoint * Hb components * channels
    %删除处理过程中的标记的坏通道
    MeasListAct(:,1)=SD.MeasListAct(1:length(SD.MeasListAct)/2,1)';
    indchan = find(MeasListAct==0);
    singdat(:,:,indchan) = nan;
    for k=1:size(procResult.s,2) % conditions
        evtind{k}=find(procResult.s(:,k)==1);
    end
    silencesind0 =[evtind{1}; evtind{2}; evtind{3}; evtind{4}] + round(25*samplerate) %增加静息为条件
    silencesind = sort(silencesind0)
    silencesind(1)=[];silencesind(end)=[];
    evtind{5} = silencesind
    %% extract event signals
    rmind=find(tIncMan==0);  % removed periods in tIncMan
    trialnum=zeros(1,length(evtind));
    for i=1:length(evtind) % conditions
        EvtSignal{i}=[];
        for j=1:length(evtind{i})  % blocks
            if ismember(evtind{i}(j),rmind)
                continue
            else
                trialnum(i)=trialnum(i)+1;
            end
            trialind=evtind{i}(j) + blockind;  % index of trial       
            trialsig=singdat(trialind,:,:)*sclConc;
            trialsigB=trialsig-repmat(mean(trialsig(baseind,:,:),1),[length(trialind) 1 1]);% baseline correction
            EvtSignal{i}(:,:,:,trialnum(i))=trialsigB;
        end
    end
  % get silenc data
    EvtSignal1(:,:,:)=squeeze(nanmean(EvtSignal{1}(:,:,:,:),4));
    EvtSignal2(:,:,:)=squeeze(nanmean(EvtSignal{2}(:,:,:,:),4)); 
    EvtSignal3(:,:,:)=squeeze(nanmean(EvtSignal{3}(:,:,:,:),4));
    EvtSignal4(:,:,:)=squeeze(nanmean(EvtSignal{4}(:,:,:,:),4));
    EvtSignal5(:,:,:)=squeeze(nanmean(EvtSignal{5}(:,:,:,:),4));
   data_all_mean1(subdat,:,:,:)=EvtSignal1;%subID * timepoints * HBs * CHs
   data_all_mean2(subdat,:,:,:)=EvtSignal2;%subID * timepoints * HBs * CHs
   data_all_mean3(subdat,:,:,:)=EvtSignal3;%subID * timepoints * HBs * CHs
   data_all_mean4(subdat,:,:,:)=EvtSignal4;%subID * timepoints * HBs * CHs
   data_all_mean5(subdat,:,:,:)=EvtSignal5;%subID * timepoints * HBs * CHs
end
   data_all_meanA(:,:,:,:,1)=data_all_mean1;%subID * timepoints * HBs * CHs * conditions
   data_all_meanA(:,:,:,:,2)=data_all_mean2;
   data_all_meanA(:,:,:,:,3)=data_all_mean3;
   data_all_meanA(:,:,:,:,4)=data_all_mean4;
   data_all_meanA(:,:,:,:,5)=data_all_mean5;
%% load data from the processed files
meandata_hbo=squeeze(data_all_meanA(:,:,1,:,:)*sclConc); %subjects *time points * channels * conditions( hbo)
disposi=[4 1 2 5 8 3 6 9 7 10 11 13 14 12 16 15 17 19 18 20];% channel display
meandata_hbo_posi= meandata_hbo(:,:,disposi,:);%subjects * time points * channels  * conditions (periods)
% compute CI
for icond = 1:size(meandata_hbo_posi,4);
    for iroi = 1:size(meandata_hbo_posi,3);
       for tps=1:size(meandata_hbo_posi,2);
            a0=meandata_hbo_posi(:,tps,iroi,icond);
            a=rmmissing(a0)
            DATA_ci(:,tps,iroi,icond)=bootci(5000,{@(x)[mean(x)],a},'alpha',0.05)
       end
    end
end

%% plotting
colors={'r','g','b','c'};%
colorseb=[0 1 1; 0 0.8 0.8;0 0.5 0.5];%0.9 0.4 0.1;1 0.5 0.5;1 0.1 0.1红 1 1 0; 0.8 0.8 0; 0.6 0.6 0黄 0 0 1;  0 0 0.8; 0 0 0.5 blue 0 1 1; 0 0.8 0.8;0 0.5 0.5 shallow green
mendat_hbo0 = squeeze(mean(meandata_hbo_posi(:,:,:,:),1));%time points * channels  * conditions( mean subjects)
mendat_hbo = squeeze(mendat_hbo0(:,:,1))
DATA_ci2=squeeze(DATA_ci(:,:,:,:))

 figure('color','w');
 for id = 1:size(meandata_hbo_posi,4);
   for ich = 1:size(meandata_hbo_posi,3);
   subplot(4,5,ich)
   t=1:size(meandata_hbo_posi,2);
   y1=DATA_ci2(1,t,ich,id);
   y2=DATA_ci2(2,t,ich,id);
   fill([t,fliplr(t)],[y1,fliplr(y2)],char(colors(id)),'edgealpha',0);%colorseb(id,:);
   alpha(0.5)
   hold on
   plot(mendat_hbo(:,ich),'color',char(colors(id)),'linewidth',2)
   hold on
   axis([0 size(meandata_hbo_posi,2) -1 1]);
   box off
    end
 end
disp('well done!')