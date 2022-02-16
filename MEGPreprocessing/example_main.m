%% Instructions
% Use this script to run your MEG preprocessing from.
%Each function is placed within a loop across all subjects.
%Each function takes two arguments: the subject name and a cfg struct
%The cfg struct should contain various fields such as data directories
%and preprocessing parameters. You can see which function cfg's require
%which fields by looking at the example script below.

%% Script
addpath('D:\bbarnett\Documents\Zero\fieldtrip-master-MVPA\')

% set deaults
ft_defaults;

%% Project Analysis
subjects = {'sub1'};

%% Preprocessing
%Here, we epoch using the photodiode presented with your stimulus.
%This is done for all MEG studies at the FIL, but if for some reason your
%study used the computer-generated triggers instead, you will have to write
%a new trialfun.m function. Here we use trialfun_photodiad.m.
%This function also downsamples data to 300Hz, does baseline correction,
%and applies a DFT filter.
for subj = 1:length(subjects)
    subject = subjects{subj};
    cfg = [];
    cfg.root = 'D:\bbarnett\Documents\Zero\data\PreprocData';
    cfg.datadir = 'D:\bbarnett\Documents\Zero\data\Raw';
    cfg.eventvalue = 1;
    cfg.prestim = 0.2;
    cfg.poststim = 1;
    cfg.saveName = 'data_preproc';
    PreprocessingTrialsPD(cfg,subject);
end

%% Visual Artefact Rejection
%Here we visually inspect artefacts and remove trials manually. This is
%done in a step by step procedure and is done entirely in the FieldTrip
%GUI. It is best to go through this process once with someone who has done
%it before, because the GUI can be confusing.
for subj = 1:length(subjects)
    subject= subjects{subj};
    
    cfg = [];
    cfg.root = 'D:\bbarnett\Documents\Zero\data\PreprocData';
    cfg.datadir = 'D:\bbarnett\Documents\Zero\data';
    cfg.stimOn = [0 0.1];
    cfg.dataName = 'data_preproc';

    PreprocessingVAR(cfg,subject)
end

%% Independent Components Analysis (ICA)
% We use ICA to remove occular and heart artefacts. It correlates each
% component with data from the FIL eye trackers and reports the two
% components with the top correlations to eye movement in the X and Y
% dimension. You can visually inspect these components before you are asked
% if you wish to remove them (you are asked to do this at the command
% line). You are then shown all the components time courses, allowing you
% to identify any heart artefacts. Again, this is helpful to do with
% someone who has done it before. NB: the ICA can take around 30 - 60
% minutes to run per subject.
for subj = 1:length(subjects)
    subject= subjects{subj};

    cfg = [];
    cfg.root = 'D:\bbarnett\Documents\Zero\data\VARData';
    cfg.datadir = 'D:\bbarnett\Documents\Zero\data';

    PreprocessingICA(cfg,subject)
end
