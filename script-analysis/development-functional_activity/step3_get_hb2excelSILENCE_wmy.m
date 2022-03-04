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
            trialind=evtind{i}(j)+ blockind;  % index of trial       
            trialsig=singdat(trialind,:,:)*sclConc;
            trialsig=trialsig-repmat(mean(trialsig(baseind,:,:),1),[length(trialind) 1 1]);
            EvtSignal{i}(:,:,:,trialnum(i))=trialsig;
        end
    end

    %% Calculate signal mean (SM) within the period of 5 to 20 s
    tHRF=blockind/samplerate;
    intind=[find(tHRF>=interval1(1),1,'first') find(tHRF<=interval1(end),1,'last')];
    for iCon=1:length(EvtSignal)
        for iCh=1:size(EvtSignal{iCon},3)
            %%% HbO
            AvgHbmat_HbO{iCon}(subdat,iCh)=squeeze(mean(squeeze(mean(EvtSignal{iCon}(intind(1):intind(end),1,iCh,:),4)),1));

            %%% HbR
            AvgHbmat_HbR{iCon}(subdat,iCh)=squeeze(mean(squeeze(mean(EvtSignal{iCon}(intind(1):intind(end),2,iCh,:),4)),1)); %想平均trial，在平均时间窗       
        end
    end
end
%% output to Excel files
%%%%%% HbO
outpaths ='D:\'
fname=strcat(outpaths,'xintianyu-data-mhbo.xls');
conditionlabel={'speech','spechbabble','babble','music','silence'};
%%% SM
for iCon=1:length(AvgHbmat_HbO)
%   triallabel={};
%     for i=1:size(AvgHbmat_HbO{iCon},1)
%         triallabel{i,1}=['Trial #' num2str(i)];
%     end
    %%% xlswrite(filename,Array,Sheet,Location)
 %   xlswrite(fname,triallabel,[conditionlabel{iCon} '_Avg'],'A2');
    xlswrite(fname,[1:size(AvgHbmat_HbO{iCon},2)],[conditionlabel{iCon} '_Avg'],'B1');
    xlswrite(fname,AvgHbmat_HbO{iCon},[conditionlabel{iCon} '_Avg'],'B2');
end

%%%%%% HbR
fname=strcat(outpaths,'xintianyu-data-mhbr.xls');
conditionlabel={'speech','spechbabble','babble','music','silence'};
%%% SM
for iCon=1:length(AvgHbmat_HbR)
%     triallabel={};
%     for i=1:size(AvgHbmat_HbR{iCon},1)
%         triallabel{i,1}=['Trial #' num2str(i)];
%     end
    %%% xlswrite(filename,Array,Sheet,Location)
 %   xlswrite(fname,triallabel,[conditionlabel{iCon} '_Avg'],'A2');
    xlswrite(fname,[1:size(AvgHbmat_HbR{iCon},2)],[conditionlabel{iCon} '_Avg'],'B1');
    xlswrite(fname,AvgHbmat_HbR{iCon},[conditionlabel{iCon} '_Avg'],'B2');
end
disp('well done!')