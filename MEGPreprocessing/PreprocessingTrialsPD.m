function [cfg,data] = PreprocessingTrialsPD(cfg0,subject)
% function PreprocessingTrialsPD(subjectID)
% PD means photodiode - we preprocess with respect to the photodiode

%% Datasets 
raw_data_dir = fullfile(cfg0.datadir,subject,'meg','raw');
dataSets = str2fullfile(raw_data_dir,'*SF025*.ds');
nDataSets = length(dataSets);
sprintf('%i data sets found',nDataSets)


%% Some settings
saveDir                     = fullfile(cfg0.root,subject);
if ~exist(saveDir,'dir'); mkdir(saveDir); end
cfgS                        = [];
cfgS.continuous             = 'yes';
cfgS.dftfilter              = 'yes';
cfgS.demean                 = 'yes'; % baseline correction on 200 ms before cue 
cfgS.baselinewindow         = [-0.2 0];
%cfgS.padding                = 10;


%% Load behavioural data for trial info
trialInfo = load(fullfile(cfg0.datadir,subject,'meg','trial_data','data.mat'));
trialInfo = trialInfo.data;


% Loop over segments here if you want to

% get the data per block 
dataS = cell(nDataSets,1);
for d = 1:nDataSets
    
    
    fprintf('\t GETTING THE DATA FOR BLOCK %d OUT OF %d \n',d,nDataSets)
    cfg                         = cfgS;
    cfg.dataset                 = dataSets{d};   
    cfg.trialdef.eventtype      = 'UPPT001';
    cfg.trialdef.eventvalue     = cfg0.eventvalue; % stimulus 1
    cfg.trialdef.pdiodetype     = 'UADC004';
    cfg.trialdef.prestim        = cfg0.prestim+0.1; %we add additional time in case PD alginment requires us to move trial's 0 point
    cfg.trialdef.poststim       = cfg0.poststim+0.1;
    cfg.trialdef.nTrls          = nTrls; % number of trials per block
    cfg.plot                   = cfg0.plot;
    cfg                         = ft_definetrial(cfg);
    
    % get it
    data                  = ft_preprocessing(cfg);    
    
    %align with photodiode
    cfg.prestim = cfg0.prestim;
    cfg.poststim = cfg0.poststim;
    dataS{d} = AlignPDiode(cfg,data); %This is where we align trigger with photodiode
    
end


% append data
cfgA = []; data = ft_appenddata(cfgA,dataS{:}); clear dataS

% add trialnumbers for later
data.trialnumbers = (1:length(data.trial))';

% add trial-info
data.trialinfo = trialInfo;

% downsample
cfg.resamplefs              = 300;
data                        = ft_resampledata(cfg, data); % resample the data

% fix sample info 
data = fixsampleinfo(data);
data = rmfield(data, 'cfg');

% save and clean up
save(fullfile(saveDir,cfg0.saveName),'data','-v7.3')
clear cfg data

end
