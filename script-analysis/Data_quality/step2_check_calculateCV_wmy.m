clear all
clc;clear;
% Calculate the coefficients of variation (CV, %) for the dual-wavelength raw intensity signals
%  1. CVchan: the CV for each channel
%  2. CVtrial: the CV for each trial
%  loading Homer data format.
%  User needs to manually reject the channels and trials using the Homer2_UI based on the results of this code.
%%54与86行所注释为计算每个通道上超出标准的trial,如果需要计算则去注释ctrl+t
%% parameter initialization
samplingrate=7.81; % in Hz
thres_CVchan=20; % in percentage
thres_CVtrial=10; % in percentage recommention: 5%~10%
stiinterval=round(20*samplingrate);  % in frame number
standperiod=round(5*samplingrate):round(20*samplingrate); % \(baseline:10~30s)beginning stand period 选取某段数据作为整个数据的基线
dirname=uigetdir('Please select a folder with nirs data'); % please make sure the directory name is same with *.wl1 and *.wl2 files
if dirname~=0
    tmp=find(dirname==filesep);
    reportfilename=dirname(tmp(end)+1:end);
    CVchan={};
    CVtrial={};
    filename={};
    CVstand=[]; % for first 10~60s stand still period
    %% load da ta
    dirinfo=dir(dirname);
    dirinfo(1:2)=[];
     subjnum=0;
    for f=1:length(dirinfo)
        [pathstr,name,ext]=fileparts(dirinfo(f).name);
        if ~strcmpi(ext,'.nirs')
            continue
        end
        subjnum=subjnum+1;
        load([dirname filesep dirinfo(f).name],'-mat')  % load *.nirs as mat files
        filename{subjnum}=dirinfo(f).name;
        
        %% calculate the CV for each channel and wavelength
        channelnum=size(d,2)/2;
        sti=find(sum(s,2));  % the onset time for each trial
        
        for w=1:2 % dual wavelengths
            for c=1:channelnum
                rawsignal=d(:,(w-1)*channelnum+c);
                CVtmp=std(rawsignal)/mean(rawsignal)*100;  % coefficient of variation
                
                CVchan{subjnum}(c,w)=CVtmp;%计算每个通道的变异系数
                
                rawsignal=d(standperiod,(w-1)*channelnum+c);
                CVtmp=std(rawsignal)/mean(rawsignal)*100;  % coefficient of variation
                
                CVstand(subjnum,c,w)=CVtmp;%整合整个数据
                
%                 %% calculate the CV for each trial and wavelength
%                 for st=1:length(sti)
%                     rawsignal=d(sti(st):sti(st)+stiinterval-1,(w-1)*channelnum+c);
%                     CVtmp=std(rawsignal)/mean(rawsignal)*100;  % coefficient of variation
%                     
%                     CVtrial{subjnum}(st,w,c)=CVtmp;
%                 end
            end
        end
    end
    
    %% decide and print out which channels and trials will be rejected
    % open a file to write
    fid=fopen(['Rejection_' reportfilename '.txt'],'w');
    fprintf(fid,'The rejection thresholds are: \r\n');
    fprintf(fid,'  CVchannel > %d%%\r\n',thres_CVchan);
    fprintf(fid,'  CVtrial > %d%%\r\n',thres_CVtrial);
    
    CVstand_w1=CVstand(:,:,1);
    CVstand_w2=CVstand(:,:,2);
    fprintf(fid,'The group averaged CVstandstill_w1 = %2.2f%%, CVstandstill_w2 = %2.2f%%\r\n \r\n',mean(CVstand_w1(:)),mean(CVstand_w2(:)));
    
    fprintf(fid,'The channels have to be rejected based on criteria are listed as belows, \r\n');
    for f=1:subjnum
        rejectchan=find(CVchan{f}(:,1)>thres_CVchan | CVchan{f}(:,2)>thres_CVchan);
        if ~isempty(rejectchan)
            fprintf(fid,'[Subject #%d]: %s \r\n',f,filename{f});
            for i=1:length(rejectchan)
                fprintf(fid,'  Channel #%d S%d-D%d, CVchannel_w1 = %2.2f%%, CVchannel_w2 = %2.2f%% \r\n',rejectchan(i),SD.MeasList(rejectchan(i),1),SD.MeasList(rejectchan(i),2),CVchan{f}(rejectchan(i),1),CVchan{f}(rejectchan(i),2));
            end
        end
    end
    
%     fprintf(fid,'\r\nThe trials have to be rejected based on criteria are listed as belows, \r\n');
%     for f=1:subjnum
%         check_printsub=0;
%         for c=1:channelnum
%             rejecttrial=find(CVtrial{f}(:,1,c)>thres_CVtrial | CVtrial{f}(:,2,c)>thres_CVtrial);
%             if ~isempty(rejecttrial)
%                 if check_printsub==0
%                     fprintf(fid,'[Subject #%d]: %s \r\n',f,filename{f});
%                     check_printsub=1;
%                 end
%                 for i=1:length(rejecttrial)
%                     fprintf(fid,'  Channel #%d S%d-D%d, Trial #%d, CVtrial_w1 = %2.2f%%, CVtrial_w2 = %2.2f%% \r\n',c,SD.MeasList(c,1),SD.MeasList(c,2),rejecttrial(i),CVtrial{f}(rejecttrial(i),1,c),CVtrial{f}(rejecttrial(i),2,c));
%                 end
%             end
%         end
%     end
%     
%     fprintf(fid,'\r\n[Caution!] User needs to manually reject the channels and trials using the Homer2_UI based on this list.');
%     fclose(fid);
    
    fprintf(['Done! Please open the Rejection_' reportfilename '.txt to find out the rejected channels and trials. \n']);
end
