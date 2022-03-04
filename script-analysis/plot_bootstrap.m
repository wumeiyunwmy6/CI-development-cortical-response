clc;clear;close all;
%% parameter initialization
sclConc = 1e6; % convert Conc from Molar to uMolar 
samplerate = 7.81; % in Hz
timewind = round(5*samplerate):round(25*samplerate); % in second,定义提取数值的时间窗
conditions={'speech','speech+babble','babble','music'};
alldcAvg=[]; % a 5D array to save all subjects' signals
MeasListAct=[];

datadir=uigetdir('Please pick up a folder of HOMER2 data');
dirinfo=dir(datadir);
dirinfo(1:2)=[];
for singdat=1:length(dirinfo)
        load([datadir filesep dirinfo(singdat).name],'-mat')
        MeasListAct(:,1)=SD.MeasListAct(1:length(SD.MeasListAct)/2,1)';
        singledata = procResult.dcAvg;
        indchan = find(MeasListAct==0);%将坏通道的数据替换为NAN
        singledata(:,:,indchan,:) = 0;%NaN
        alldcAvg(singdat,:,:,:,:)=singledata;  %  filename *timepoint * Hb components * channels * conditions        
        tHRF=procResult.tHRF;
end

%% load data from the processed files
meandata_hbo=squeeze(alldcAvg(:,:,1,:,:)*sclConc); %subjects *time points * channels * conditions( hbo)
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