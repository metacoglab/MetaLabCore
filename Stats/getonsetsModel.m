% Script to get design matrix onsets
%
% Requires regs of no interest have already been created from
% getmultiregs.m
%
% Loads into spm 1st level design matrix and estimates job
%
% Steve Fleming 2008

clear all
cwd = pwd;

% Options for processing
compute_conditions = 1;
construct_design = 1;
estimate = 1;

spmdir =  '/Users/sfleming/Dropbox/Utils/spm12';
addpath(spmdir);

%% Change according to your directory strucutre and scan parameters
dir_behav = '/Users/sfleming/Dropbox/Research/NYU/Self-other/task/localizer/locData';
dir_base    = '/Users/sfleming/Documents/Data/Self-Other';
dir_epi     = 'Functional';
dir_stats = 'StatsDir_loc';
sess_prfx   = 'sess';
scanK = 4; % hack because localizer data are stored as session 4 of EPI data
name_subj       = {'sub22','sub23','sub24','sub25','sub26','sub27','sub29','sub30','sub31','sub32','sub34','sub35','sub36','sub37','sub38','sub39','sub40','sub41','sub42','sub44','sub45'};
subNo = [22 23 24 25 26 27 29 30 31 32 34 35 36 37 38 39 40 41 42 44 45];

fs = filesep;
blockNo = 1;
nslices = 42;
TR = 2.3352;
hpcutoff = 128; % hp filter

for n = 1:length(name_subj)
    
    % Go to subject directory
    cd([dir_base fs name_subj{n}]);
    % if the intended stats directory does not exits, make it and go into it
    if exist(dir_stats) ~= 7
        mkdir(dir_stats);
        cd(dir_stats);
    else
        % if it does exist, go into it and delete existing contrast files
        % as we are re-estimating
        cd(dir_stats);
        delete('SPM.mat','*.img','*.hdr');
    end
    
    outputDir = [dir_base fs name_subj{n} fs dir_stats];
    
    %=========================================================================
    %% Get onsets in scans from behavioural datafiles and define images
    %======================================================================
    cd(cwd);   
    for k = 1:blockNo;
        if compute_conditions
            disp(['Computing event onsets for subject ' name_subj{n} ', session ' num2str(k)]);
            % Define behavioural data path
            datafile = ['locData_sub_' num2str(subNo(n))];
            cd(dir_behav);
            load(datafile)
            cd(cwd);
            
            % Compute times of each miniblock onset in secs
            scanStart = locDATA.timing.blockStart(1);
            motionOnsets = locDATA.timing.blockStart - scanStart;
            leftOnsets = motionOnsets(locDATA.d == 0);
            rightOnsets = motionOnsets(locDATA.d == 1);
            
            names = [];
            onsets = [];
            durations = [];
                        
            % Example of two conditions, one with a parametric modulator
            names{1} = 'R_motion';
            onsets{1} = rightOnsets;
            durations{1} = 12;
            pmod(1).name{1} = 'RT'
            pmod(1).param{1} = RT;
            pmod(1).poly{1} = 1;
            % Use this to switch off orthogonalisation of pmods (only relevant if you have more than one per condition):
            orth{1} = 0;
            
            names{2} = 'L_motion';
            onsets{2} = leftOnsets;
            durations{2} = 12;
            
            cd(outputDir);
            conditionFile = sprintf('conditions%d.mat',k);
            
            pmod = [];
            save(conditionFile, 'onsets', 'names', 'durations', 'pmod', 'orth');
            
        end
        
        %==========================================================================
        %% Construct design matrix
        %==========================================================================
        
        % Load files we have just created
        epiDir = [dir_base fs name_subj{n} fs dir_epi fs sess_prfx num2str(scanK)];
        mCorrFile = spm_select('List',epiDir,'^rp.*\.txt$');
        conditionFile = sprintf('conditions%d.mat',k);
        
        % Assign .mat file with onsets/names/pmods in to path
        conditionPath = [outputDir fs conditionFile];
        multiregPath = [epiDir fs mCorrFile];
        
        % get epi files for this session
        epiDir = [dir_base fs name_subj{n} fs dir_epi fs sess_prfx num2str(scanK)];
        % select scans and concatenate
        f   = spm_select('List', epiDir, '^swuf.*\.nii$');     % Select smoothed normalised images
        files  = cellstr([repmat([epiDir fs],size(f,1),1) f]);
        % clear temporary variables for next run
        jobs{1}.stats{1}.fmri_spec.sess(k).scans = files;
        f = []; files = [];
        
        jobs{1}.stats{1}.fmri_spec.sess(k).multi = {conditionPath};
        jobs{1}.stats{1}.fmri_spec.sess(k).multi_reg = {multiregPath};
        % high pass filter
        jobs{1}.stats{1}.fmri_spec.sess(k).hpf = hpcutoff;
        jobs{1}.stats{1}.fmri_spec.sess(k).cond = struct([]);
        jobs{1}.stats{1}.fmri_spec.sess(k).regress = struct([]);
    end
    
    %==========================================================================
    %======================================================================
    jobs{1}.stats{1}.fmri_spec.dir = {outputDir};
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
    if construct_design
        cd(outputDir);
        % save and run job
        save specify.mat jobs
        disp(['RUNNING model specification for subject ' name_subj{n}]);
        spm_jobman('run','specify.mat');
        clear jobs
    end
    
    % Ensure implicit masking is switched off
    load SPM
    SPM.xM.TH = repmat(-Inf, length(SPM.xM.TH), 1);
    SPM.xM.I = 0;
    save SPM SPM
    
    %% Estimate
    % setup job structure for model estimation and estimate
    % ---------------------------------------------------------------------
    if estimate
        jobs{1}.stats{1}.fmri_est.spmmat = {[outputDir fs 'SPM.mat']};
        save estimate.mat jobs
        disp(['RUNNING model estimation for subject ' name_subj{n}])
        spm_jobman('run','estimate.mat');
        clear jobs
    end
end
cd(cwd);
