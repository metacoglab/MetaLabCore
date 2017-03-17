function getonsets_singleTrial(scans, trialOnsets, trialDurations, outputDirectory, includeMotion, TR, nslices, hpcutoff)
% function getonsets_singleTrial(scans, trialOnsets, trialDurations, outputDirectory, includeMotion, TR, nslices, hpcutoff)
%
% Function to build and and estimate design matrix
% for single-trial betas
%
% scans - 1 x Nsession cell array of scan images (e.g. swauf*.nii)
% trialOnsets - 1 x Nsession cell array of onset time vector in seconds
% trialDurations - 1 x Nsession cell array of duration vectors (each entry can
% also be a scalar if constant)
% outputDirectory - path to where you want to write this subject's model
%
% includeMotion - if 1 then looks for rp*.txt files in scan directory and
% includes as covariates (with first derivative)
% TR - TR in secs
% nslices - number of slices in volume in secs (for setting microtime
% resolution to middle of volume)
%
%
% Steve Fleming 2015

fs = filesep;
cwd = pwd;
try
    spmdir = fileparts(which('spm'));
catch
    error('Please add SPM to the path')
end

nsess = length(scans);

for k = 1:nsess
    
    pmod = [];
    onsets = [];
    durations = [];
    names = [];
    
    [epiDir file ext] = fileparts(char(scans{k}(1,:)));
    
    for i = 1:length(trialOnsets{k})
        names{i} = ['AUC' num2str(i)];
        onsets{i} = trialOnsets{k}(i);
        if length(trialDurations{k}) == 1
            durations{i} = trialDurations{k};
        else
            durations{i} = trialDurations{k}(i);
        end
    end
    
    % Get text file with movement regressors and concatenate with
    % first derivative
    mCorrFile = spm_select('List',epiDir,'^rp_af.*\.txt$');
    M = textread([epiDir fs mCorrFile]);
    R = [M [zeros(1,6); diff(M)]];
    
    cd(outputDirectory);
    multiFile = sprintf('multireg%d.mat',k);
    save(multiFile, 'R');
    
    conditionFile = ['conditions' num2str(k) '.mat'];
    save(conditionFile, 'onsets', 'names', 'durations', 'pmod');
    cd(cwd);
    
    % Assign .mat file with onsets/names/pmods in to path
    conditionPath = [outputDirectory fs conditionFile];
    multiregPath = [outputDirectory fs multiFile];
    
    % clear temporary variables for next run
    jobs{1}.stats{1}.fmri_spec.sess(k).scans = scans{k};
    
    jobs{1}.stats{1}.fmri_spec.sess(k).multi = {conditionPath};
    if includeMotion
        jobs{1}.stats{1}.fmri_spec.sess(k).multi_reg = {multiregPath};
    else
        jobs{1}.stats{1}.fmri_spec.sess(k).multi_reg = {};
    end
    % high pass filter
    jobs{1}.stats{1}.fmri_spec.sess(k).hpf = hpcutoff;
    jobs{1}.stats{1}.fmri_spec.sess(k).cond = struct([]);
    jobs{1}.stats{1}.fmri_spec.sess(k).regress = struct([]);
end

jobs{1}.stats{1}.fmri_spec.dir = {outputDirectory};
% timing variables
jobs{1}.stats{1}.fmri_spec.timing.units     = 'secs';
jobs{1}.stats{1}.fmri_spec.timing.RT        = TR;
jobs{1}.stats{1}.fmri_spec.timing.fmri_t    = nslices;
jobs{1}.stats{1}.fmri_spec.timing.fmri_t0   = nslices/2;

% basis functions
jobs{1}.stats{1}.fmri_spec.bases.hrf.derivs         = [0 0];
% model interactions (Volterra) OPTIONS: 1|2 = order of convolution
jobs{1}.stats{1}.fmri_spec.volt                     = 1;
% global normalisation
jobs{1}.stats{1}.fmri_spec.global                   = 'None';
% explicit masking
jobs{1}.stats{1}.fmri_spec.mask                     = {[spmdir fs 'tpm/mask_ICV.nii']};
% serial correlations
jobs{1}.stats{1}.fmri_spec.cvi                      = 'AR(1)';
% no factorial design
jobs{1}.stats{1}.fmri_spec.fact = struct('name', {}, 'levels', {});


%==========================================================================
%% run model specification
%==========================================================================
cd(outputDirectory);
% save and run job
save specify.mat jobs
disp('Specifying model');
spm_jobman('run','specify.mat');
clear jobs

% Ensure orthogonalisation and implicit masking is switched off
load SPM
SPM.xM.TH = repmat(-Inf, length(SPM.xM.TH), 1);
SPM.xM.I = 0;
for k = 1:nsess
    for u = 1:length(SPM.Sess(k).U)
        SPM.Sess(k).U(u).orth = 0;
    end
end
save SPM SPM

%% Estimate
% setup job structure for model estimation and estimate
% ---------------------------------------------------------------------
jobs{1}.stats{1}.fmri_est.spmmat = {[outputDirectory fs 'SPM.mat']};
cd(outputDirectory);
save estimate.mat jobs
disp('Estimating model')
spm_jobman('run','estimate.mat');
clear jobs
cd(cwd);