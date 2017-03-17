clear all
cwd = pwd;
fs = filesep;

addpath(genpath('~/Dropbox/Utils/spm12'));

%% Change according to your directory strucutre and scan parameters
dir_base    = '/Users/sfleming/Documents/Data/Self-Other';
dir_stats = 'StatsDir_exp';
name_subj       = {'sub22','sub23','sub24','sub25','sub26','sub27','sub29','sub30','sub31','sub32','sub34','sub35','sub36','sub37','sub38','sub39','sub40','sub41','sub42','sub44','sub45'};

% Check mask images created during first-level model
for n = 1:length(name_subj)
    
        maskDir = [dir_base fs name_subj{n} fs dir_stats];
        f   = spm_select('List', epiDir, '^mask.*\.nii$');     % Select smoothed normalised images
        files  = cellstr([repmat([epiDir fs],size(f,1),1) f]);
        file_list(n,:) = files; % select the 10th functional image to show
end

V = spm_vol(file_list);
spm_check_registration(V);