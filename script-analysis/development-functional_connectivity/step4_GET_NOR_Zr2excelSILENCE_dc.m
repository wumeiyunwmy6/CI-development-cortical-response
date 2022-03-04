%这个脚本是为了获得每个个体的相关系数矩阵，这个方式的相关的获取主要是基于d中每个条件的onset得到的
clear;clc; close all
%% parameter initialization
scales=[0,1]
conditions={'speech','speechbabble','babble','music','silence'};
channelnum=20;
samplerate = 7.81; % in Hz
% ROI data
frotal_l=[1 2];frotal_r=[11 12];%前额叶
parital_l=[3 4 5];parital_r=[13 14 15];%顶叶
temporal_l=[6 7 8];temporal_r=[16 17 18];%颞叶
occipital_l=[9 10];occipital_r=[19 20];%枕叶

sclConc = 1e6; % convert Conc from Molar to uMolar
blockint=[-5 30]; % block interval in second, please include baseline period(epoch)
interval1=[1 20]; % the interval for evaluating mean values in second(mean)
blockind=[round(blockint(1)*samplerate):round(blockint(2)*samplerate)];
baseind=find(blockind<0);
tHRF=blockind/samplerate;
intind=[find(tHRF>=interval1(1),1,'first') find(tHRF<=interval1(end),1,'last')];
%% load *.nirs files within the folder
datadir=uigetdir('Please pick up a folder of HOMER2 data');
dirinfo=dir(datadir);
dirinfo(1:2)=[];

MeasListAct=[];
AvgHbmat_HbO0=[];
AvgHbmat_HbO=[];  %{iCon} trials * channels 
AvgHbmat_HbR=[];  %{iCon} trials * channels
arraych=[1 4 3 6 9 2 5 8 7 10 11 13 15 17 19 12 14 16 18 20]
for subdat=1:length(dirinfo)
    load([datadir filesep dirinfo(subdat).name],'-mat')
    singdat=[];
   % tHRF = procResult.tHRF;
    singdat = procResult.dc;% timepoint * Hb components * channels
    %删除处理过程中的标记的坏通道
    MeasListAct(:,1)=SD.MeasListAct(1:length(SD.MeasListAct)/2,1)';
    indchan = find(MeasListAct==0);
    singdat(:,:,indchan) = nan;
    singdat(:,:,:) = singdat(:,:,arraych) %将数据按照远近排列
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
            trialind=evtind{i}(j)+ blockind;  % indices of trial       
            trialsig=singdat(trialind,:,:)*sclConc;
            trialsig=trialsig-repmat(mean(trialsig(baseind,:,:),1),[length(trialind) 1 1]);
            trialsig2=normalize(squeeze(trialsig(intind(1):intind(end),1,:)),1);
            EvtSignal{i}(:,:,:,trialnum(i))=trialsig2;
        end
    end

    %% Calculate data
    meandata_hbo_posi=[];
    for iCon=1:length(EvtSignal)
        %%% CH
        data_trials{iCon}=[];AvgHbmat_HbO_subdat{iCon}=[];data_corrvaluech=[];data_norcorrvaluech=[];
        data_trials{iCon}(:,:,:)=permute(squeeze(EvtSignal{iCon}(intind(1):intind(end),1,:,:)),[2 1 3]); %timepoint * hb*channel*trial---->channels *timepoint *trial
        AvgHbmat_HbO_subdat{iCon}(:,:) = reshape(data_trials{iCon},size(data_trials{iCon},1),[])'
        data_corrvaluech=corr(AvgHbmat_HbO_subdat{iCon});%求相关
        % 获取fisher转换的值
        s1=size(data_corrvaluech);
        data_norcorrvaluech=zeros(s1);
        for i = 1:s1(1);
            for j = 1:s1(2);
               data_norcorrvaluech(i,j)=0.5*log((1+data_corrvaluech(i,j))/(1-data_corrvaluech(i,j)))
               data_norcorrvaluech(data_norcorrvaluech==inf) = nan; %将A中等于x的值全部替换为X
            end
        end
     corrdata_subs_condsch(iCon,subdat,:,:) = data_corrvaluech;
     corrdata_subs_conds_Zrch(iCon,subdat,:,:) = data_norcorrvaluech;
     
         %%% ROI
    data_corrvalueroi=[];data_norcorrvalueroi=[];
    meandata_hbo_posi{iCon}(1,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,frotal_l),2));%ROI*subjects * time points  * conditions * times(periods)  
    meandata_hbo_posi{iCon}(2,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,parital_l),2));%ROI*subjects * time points  * conditions * times(periods)
    meandata_hbo_posi{iCon}(3,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,temporal_l),2));%ROI*subjects * time points  * conditions * times(periods)
    meandata_hbo_posi{iCon}(4,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,occipital_l),2));%ROI*subjects * time points  * conditions * times(periods)
    meandata_hbo_posi{iCon}(5,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,frotal_r),2));%ROI*subjects * time points  * conditions * times(periods)
    meandata_hbo_posi{iCon}(6,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,parital_r),2));%ROI*subjects * time points  * conditions * times(periods)
    meandata_hbo_posi{iCon}(7,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,temporal_r),2));%ROI*subjects * time points  * conditions * times(periods)
    meandata_hbo_posi{iCon}(8,:)= squeeze(nanmean(AvgHbmat_HbO_subdat{iCon}(:,occipital_r),2));%ROI*subjects * time points  * conditions * times(periods)
    data_corrroi = squeeze(meandata_hbo_posi{iCon}(:,:))
    data_corrvalueroi=corr(data_corrroi');%求相关
     % 获取fisher转换的值
        s1r=size(data_corrvalueroi);
        data_norcorrvalueroi=zeros(s1r);
        for ir = 1:s1r(1);
            for jr = 1:s1r(2);
               data_norcorrvalueroi(ir,jr)=0.5*log((1+data_corrvalueroi(ir,jr))/(1-data_corrvalueroi(ir,jr)))
               data_norcorrvalueroi(data_norcorrvalueroi==inf) = nan; %将A中等于x的值全部替换为X
            end
        end
    corrdata_subs_condsroi(iCon,subdat,:,:) = data_corrvalueroi;
    corrdata_subs_conds_Zrroi(iCon,subdat,:,:) = data_norcorrvalueroi;
    end
end
%原相关图
corrdata_subs_conds_times_meansubch = squeeze(nanmean(corrdata_subs_condsch,2));
% plotting
figure('color','w');
for icd = 1:size(corrdata_subs_conds_times_meansubch,1)
     subplot(2,3,icd)
     data_plot =squeeze(corrdata_subs_conds_times_meansubch(icd,:,:))
     hold on
     imagesc(data_plot,scales)
     box off
end
%原相关图
corrdata_subs_conds_times_meansubroi = squeeze(nanmean(corrdata_subs_condsroi,2));
% plotting
figure('color','w');
for icd = 1:size(corrdata_subs_conds_times_meansubroi,1)
     subplot(2,3,icd)
     data_plotroi =squeeze(corrdata_subs_conds_times_meansubroi(icd,:,:))
    % data_plot
    % data_plot=squeeze(corrdata_subs_conds_times_Zr_meansub(jt,icd,:,:))%画Z图
     hold on
     imagesc(data_plotroi,scales)
     box off
end
%CH
speechch= permute(squeeze(corrdata_subs_conds_Zrch(1,:,:,:)),[2 3 1]);
sin_speechch=reshape(speechch,20,[]); 
musicch= permute(squeeze(corrdata_subs_conds_Zrch(4,:,:,:)),[2 3 1]);
sin_musicch=reshape(musicch,20,[]); 
babblech= permute(squeeze(corrdata_subs_conds_Zrch(3,:,:,:)),[2 3 1]);
sin_babblech=reshape(babblech,20,[]); 
spechbabblech= permute(squeeze(corrdata_subs_conds_Zrch(2,:,:,:)),[2 3 1]);
sin_spechbabblech=reshape(spechbabblech,20,[]); 
silence= permute(squeeze(corrdata_subs_conds_Zrch(5,:,:,:)),[2 3 1]);
sin_silence=reshape(silence,20,[]); 
sin_speechch=sin_speechch'
sin_musicch=sin_musicch'
sin_babblech=sin_babblech'
sin_spechbabblech=sin_spechbabblech'
sin_silence=sin_silence'
outpaths ='D:\BNU_CI_NIRS\';
fname=strcat(outpaths,'CI_T0_task_chs_0103','.xls');% '_',times{itime},
xlswrite(fname,sin_speechch, 'speech_Avg','B2');
xlswrite(fname,sin_musicch, 'music_Avg','B2');
xlswrite(fname,sin_babblech, 'babble_Avg','B2');
xlswrite(fname,sin_spechbabblech, 'spechbabble_Avg','B2');
xlswrite(fname,sin_silence, 'silence_Avg','B2');

% ROI
speech11= permute(squeeze(corrdata_subs_conds_Zrroi(1,:,:,:)),[2 3 1]);
sin_speech=reshape(speech11,8,[]); 
music11= permute(squeeze(corrdata_subs_conds_Zrroi(4,:,:,:)),[2 3 1]);
sin_music=reshape(music11,8,[]); 
babble11= permute(squeeze(corrdata_subs_conds_Zrroi(3,:,:,:)),[2 3 1]);
sin_babble=reshape(babble11,8,[]); 
spechbabble11= permute(squeeze(corrdata_subs_conds_Zrroi(2,:,:,:)),[2 3 1]);
sin_spechbabble=reshape(spechbabble11,8,[]); 
silence11= permute(squeeze(corrdata_subs_conds_Zrroi(5,:,:,:)),[2 3 1]);
sin_silence=reshape(silence11,8,[]); 
sin_speech=sin_speech'
sin_music=sin_music'
sin_babble=sin_babble'
sin_spechbabble=sin_spechbabble'
sin_silence=sin_silence'
outpaths ='D:\BNU_CI_NIRS\';
fname=strcat(outpaths,'CI_T0_task_ROI_0103','.xls');% '_',times{itime},
xlswrite(fname,sin_speech, 'speech_Avg','B2');
xlswrite(fname,sin_music, 'music_Avg','B2');
xlswrite(fname,sin_babble, 'babble_Avg','B2');
xlswrite(fname,sin_spechbabble, 'spechbabble_Avg','B2');
xlswrite(fname,sin_silence, 'silence_Avg','B2')

disp('well done!')