function BS_1stlevelModel
% Script to set up conrasts for 1st level analysis
%
% Requires that model estimation for all subjects being analysed be
% completed first by getonsetsModel.m
%
% Steve Fleming 2008
% Based on code by Christian Kaul 2007

% =========================== Set up contrasts ============================
% =========================================================================

cwd = pwd;

%% Change according to your scan parameters and directory structure
dir_base    = '/path/to/mri/data';
dir_epi     = 'Functional';
dir_stats = 'yourStatsDir';
sess_prfx   = 'sess';
name_subj       = {'sub22','sub23','etc'};

blockNo = 1;

cwd = pwd;

fs = filesep;
cd(cwd);
k = 6; % number of motion regs
    
spm fmri
for s0 = 1 : length(name_subj)
    % Contrast names
    T.contrasts = {'Motion > baseline', 'L > R motion'};
   
   	% You need as many rows here as entries in the cell array above
    T.contrastVectors(1,:) =    [repmat([1 1 zeros(1,k)],1,blockNo) zeros(1,blockNo)];
    T.contrastVectors(2,:) =    [repmat([1 -1 zeros(1,k)],1,blockNo) zeros(1,blockNo)];
    
    j = 1;
    jobs{1}.stats{1}.con.spmmat    = {[dir_base fs name_subj{s0} fs dir_stats fs 'SPM.mat']};
    
    %     Specify tcontrasts
    for cont_nr = 1:length(T.contrasts)
        contrasttype = T.contrasts{cont_nr};
        contr_input = T.contrastVectors(cont_nr,:);
        
        % setup job structure for contrasts
        jobs{1}.stats{1}.con.consess{j}.tcon.name           = contrasttype;
        jobs{1}.stats{1}.con.consess{j}.tcon.convec         = contr_input;
        jobs{1}.stats{1}.con.consess{j}.tcon.sessrep        = 'none';
        j=j+1;
    end
    
    % if 1 then all existing contrasts are deleted
    jobs{1}.stats{1}.con.delete                         = 1;
    
    outputDir = [dir_base fs name_subj{s0} fs dir_stats];
    cd (outputDir);
    % save and run job
    save contrasts.mat jobs
    disp(['RUNNING contrast specification for subject number  ' name_subj{s0}]);
    spm_jobman('run','contrasts.mat');
    disp(['Contrasts created for ' num2str(s0) ' subjects']);
    clear jobs
    
end   % end of subject loop

cd(cwd);
