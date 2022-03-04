clc;clear;
sclConc = 1e6;
%% input .nirs data
datadir=uigetdir('Please pick up a folder of nirs data');
dirinfo=dir(datadir);
dirinfo(1:2)=[];
%get_rest = 7.81*30;%20s的刺激时间，再加10的hrf反应时间，即将刺激呈现之后的10s为rest的onset时间
% strct included hbo,hbr,hbt,tHRF,number of trials,channels,sampling...
for subdat=1:length(dirinfo)
    load([datadir filesep dirinfo(subdat).name],'-mat') ;
    nirsdata.oxyData = squeeze(procResult.dc(:,1,:)*sclConc)%;
    nirsdata.dxyData = squeeze(procResult.dc(:,2,:)*sclConc)%;
    nirsdata.totalData = squeeze(procResult.dc(:,3,:)*sclConc)%;
    nirsdata.tHRF = t;
    nirsdata.vector_onset = procResult.s(:,1);
   % 获取每个事件的onset时间 
    typeevt1={find(procResult.s(:,1)==1)};
    nirs_data.vector_onset.evt1 = cell2mat(typeevt1)
    typeevt2={find(procResult.s(:,2)==1)};
    nirs_data.vector_onset.evt2 = cell2mat(typeevt2)
    typeevt3={find(procResult.s(:,3)==1)};
    nirs_data.vector_onset.evt3 = cell2mat(typeevt3)
    typeevt4={find(procResult.s(:,4)==1)};
    nirs_data.vector_onset.evt4 = cell2mat(typeevt4)
  %  nirs_data.vector_onset.evt5= [typeevt1{1}'+ get_rest, typeevt2{1}'+ get_rest,typeevt3{1}'+ get_rest,typeevt4{1}'+ get_rest]
 %   nirs_data.vector_onset.evt5 = cell2mat(typeevt1)- get_rest;
        rest_durtion = round(0.5*157)
        a_durtion = 157;
        design_inf{1,1}='data_name'
        design_inf{1,2}='speech'
        design_inf{1,3}='speech_noise'
        design_inf{1,4}='noise'
        design_inf{1,5}='music'
 %       design_inf{1,6}='rest'
        design_inf{subdat+1,1} = dirinfo(subdat).name
        design_inf{subdat+1,2}(:,1) = nirs_data.vector_onset.evt1
        design_inf{subdat+1,2}(:,2) = repmat(a_durtion,length(nirs_data.vector_onset.evt1),1)
        design_inf{subdat+1,3}(:,1) = nirs_data.vector_onset.evt2
        design_inf{subdat+1,3}(:,2) = repmat(a_durtion,length(nirs_data.vector_onset.evt2),1)
        design_inf{subdat+1,4}(:,1) = nirs_data.vector_onset.evt3
        design_inf{subdat+1,4}(:,2) = repmat(a_durtion,length(nirs_data.vector_onset.evt3),1)
        design_inf{subdat+1,5}(:,1) = nirs_data.vector_onset.evt4
        design_inf{subdat+1,5}(:,2) = repmat(a_durtion,length(nirs_data.vector_onset.evt4),1)
%         design_inf{subdat+1,6}(:,1) = nirs_data.vector_onset.evt5
%         design_inf{subdat+1,6}(:,2) = repmat(rest_durtion,length(nirs_data.vector_onset.evt5),1)
  
    nirsdata.nch = size(nirsdata.oxyData,2);
    nirsdata.T = 0.128;% 1/7.81
    nirsdata.nch = 20
    nirsdata.probeSet ={}
    nirsdata.exception_channel = 1:20
    nirsdata.subject= dirinfo(subdat).name
    nirsdata.system = 'NIRX';
    nirsdata.probe2d ={}
    nirsdata.probe3d ={}
    nirsdata.preprocessSet = {}
    nirsdata.fs = 7.81
    nirsdata.wavelength = [760 850]
    nirsdata.validchannel=SD.MeasListAct(1:20,:)
    outputroot=['D:\BNU_CI_NIRS\test_NIRS_KIT\NH0.002-0.5\'];
    outfilePath =[outputroot, dirinfo(subdat).name,'.mat'];
    save(outfilePath,'nirsdata');  
end
disp('well done!')