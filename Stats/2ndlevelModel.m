function BS_1stlevelModel
% Script to set up conrasts for 1st level analysis
%
% Requires that model estimation for all subjects being analysed be
% completed first by getonsetsModel.m
%
% Steve Fleming 2008-2015
% Based on code by Christian Kaul 2007

% =========================== Set up contrasts ============================
% =========================================================================

cwd = pwd;

spmdir =  '/path/to/spm12';
addpath(spmdir);

%% Change according to your scan parameters and directory structure
dir_base    = '/path/to/mri/data';
dir_stats = 'yourStatsDir';	% where to get 1st level contrast images from
dir_results = 'GLM1';	% name of this GLM
secondlevelDir = 'Results';	% where to put all second level folders
name_subj       = {'sub22','sub23','etc'};

cwd = pwd;

fs = filesep;

spm fmri
contrastNames = {'Motion - static', 'L > R motion'};
conImages = {'con_0001.nii,1', 'con_0002.nii,1'};	% these correspond to the relevant contrast images in your first-level script

for j = 1:length(contrastNames)
    
    contrastFolder = [dir_base fs secondlevelDir fs dir_results fs contrastNames{j}];
    
    % if the intended resultsFolder directory does not exits, make it and go into it
    if exist(contrastFolder,'dir') ~= 7
        mkdir(contrastFolder);
        cd(contrastFolder);
    else
        % if it does exist, go into it and delete its contents.
        % change this for more than one 2nd level test
        cd(contrastFolder);
        delete('*.*');
    end
    
    %setup job structure for 2nd level t-test of individual contrasts
    %---------------------------------------------------------------------
    for s0 = 1 : length(name_subj)  % select con image from every subject
        spmDir = [dir_base fs name_subj{s0} fs dir_stats];
        conImg = conImages{j};
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{s0}    = [spmDir fs conImg] ;
    end
    
    % Check if there is a covariate for this contrast, and compute
    if ~isempty(cov)
        for n = 1:length(cov)
            matlabbatch{1}.spm.stats.factorial_design.cov(n) = struct('c',cov{n}','cname',covName{n},'iCFI',1,'iCC',1);
        end
    else
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c',{},'cname',{},'iCFI',{},'iCC',{});
    end
    
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = [];
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {[spmdir fs 'tpm/mask_ICV.nii']};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = [];
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = [];
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{1}.spm.stats.factorial_design.dir = {contrastFolder};
    
    % run 2nd level test
    % ---------------------------------------------------------------------
    % save and run job
    save second_level.mat matlabbatch
    disp(['RUNNING second level test']);
    spm_jobman('run','second_level.mat');
    clear matlabbatch
    
    % Ensure implicit masking is switched off
    load SPM
    SPM.xM.I = 0;
    save SPM SPM
    
    jobs{1}.stats{1}.fmri_est.spmmat = {[contrastFolder fs 'SPM.mat']};
    save estimate.mat jobs
    disp(['RUNNING model estimation'])
    spm_jobman('run','estimate.mat');
    clear jobs
    
    % Specify one-sample tcontrasts
    % ---------------------------------------------------------------------
    contrasttype = contrastNames{j};
    contr_input = [1];              % one-sample RFX significance
    
    % setup job structure for 2nd level contrast using newly created
    % SPM.mat
    jobs{1}.stats{1}.con.spmmat    = {[contrastFolder fs 'SPM.mat']};
    jobs{1}.stats{1}.con.consess{1}.tcon.name           = contrasttype;
    jobs{1}.stats{1}.con.consess{1}.tcon.convec         = contr_input;
    jobs{1}.stats{1}.con.consess{1}.tcon.sessrep        = 'none';
    jobs{1}.stats{1}.con.delete                         =1;
    
    % save and run job
    save contrasts.mat jobs
    disp(['RUNNING 2nd level test for 1st level contrast  ' contrastNames{j}]);
    spm_jobman('run','contrasts.mat');
    clear jobs
    
end

cd(cwd);
