function fil_mri_organise(which_subjects)
% function fil_mri_organise(which_subjects)
% Sorts unzipped folders and deletes dummy volumes
% Details for each subject must be entered in 'fil_subject_details'
% If the data for a subject has already been sorted, then that subject
% is skipped
% which_subjects is a vector
%
% Steve Fleming & Dan Bang, FIL, 07/06/2016

%% Current directory
cwd = pwd;

%% Load subject details (see fil_subject_details)
load('subject_details.mat');

%% Numbers 
n_fun = 5; % n functional run folders (main task)
n_dum = 4; % n dummys

%% Directory paths and targets
fs          = filesep;
dbpath      = getDropbox(0);
dir_loc     = 'Localiser';
dir_funct   = 'Functional';
dir_block   = 'sess';
dir_struct  = 'Structural';
dir_fm      = 'Fieldmaps';
dir_root    = [dbpath,fs,'ego',fs,'matlab',fs,'ucl',fs,'sensory_vs_decision',fs,'brain',fs,'data'];

%% Loop through scans
for i_s = which_subjects;
    
    %% localiser
    % paths
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.localiser)];
    new_path  = [dir_root,fs,'s',num2str(i_s),fs,dir_loc];
    % reorganise
    if exist(old_path,'dir')==7;
    fname     = spm_select('List',old_path,'^s.*\.nii$');
    old_files = cellstr([repmat([old_path fs],size(fname,1),1) fname]); 
    new_files = cellstr([repmat([new_path fs],size(fname,1),1) fname]); 
    mkdir(new_path); for i = 1:size(old_files,1); copyfile(old_files{i},new_files{i}); end; rmdir(old_path,'s'); 
    end

    %% structural
    % paths
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.structural)];
    new_path  = [dir_root,fs,'s',num2str(i_s),fs,dir_struct];
    % reorganise
    if exist(old_path,'dir')==7;
    fname     = spm_select('List',old_path,'^s.*\.nii$');
    old_files = cellstr([repmat([old_path fs],size(fname,1),1) fname]); 
    new_files = cellstr([repmat([new_path fs],size(fname,1),1) fname]); 
    mkdir(new_path); for i = 1:size(old_files,1); copyfile(old_files{i},new_files{i}); end; rmdir(old_path,'s'); 
    end
    
    %% functional
    % loop through functional scans
    for j = 1:n_fun;
    % paths
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.functional(j))];
    new_path  = [dir_root,fs,'s',num2str(i_s),fs,dir_funct,fs,dir_block,num2str(j)];
    % reorganise
    if exist(old_path,'dir')==7; 
    fname     = spm_select('List',old_path,'^f.*\.nii$');
    old_files = cellstr([repmat([old_path fs],size(fname,1),1) fname]); 
    new_files = cellstr([repmat([new_path fs],size(fname,1),1) fname]); 
    mkdir(new_path); for i = 1:size(old_files,1); copyfile(old_files{i},new_files{i}); end; rmdir(old_path,'s');
    fname   = spm_select('List', new_path, '^f.*\.nii$');
    cd(new_path); for d = 1:n_dum; delete(fname(d,:)); fprintf('Deleted dummy scan %s.\n',fname(d,:)); end; cd(cwd);
    end
    end
    
    %% motion
    % paths
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.motion)];
    new_path  = [dir_root,fs,'s',num2str(i_s),fs,dir_funct,fs,dir_block,num2str(n_fun+1)];
    % reorganise
    if exist(old_path,'dir')==7;
    fname     = spm_select('List',old_path,'^f.*\.nii$');
    old_files = cellstr([repmat([old_path fs],size(fname,1),1) fname]); 
    new_files = cellstr([repmat([new_path fs],size(fname,1),1) fname]); 
    mkdir(new_path); for i = 1:size(old_files,1); copyfile(old_files{i},new_files{i}); end; rmdir(old_path,'s');
    fname   = spm_select('List', new_path, '^f.*\.nii$');
    cd(new_path); for d = 1:n_dum; delete(fname(d,:)); fprintf('Deleted dummy scan %s.\n',fname(d,:)); end; cd(cwd);
    end
    
    %% fieldmaps
    for j = 1:n_fun+1
        % maps 1-2 (phase)
        % paths
        old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.fieldmaps(1))];
        new_path  = [dir_root,fs,'s',num2str(i_s),fs,dir_fm,fs,dir_funct,fs,dir_block,num2str(j)];
        % reorganise
        if exist(old_path,'dir')==7;
        fname     = spm_select('List', old_path, '^s.*\.nii$');
        old_files = cellstr([repmat([old_path fs],size(fname,1),1) fname]); 
        new_files = cellstr([repmat([new_path fs],size(fname,1),1) fname]); 
        mkdir(new_path); for i = 1:size(old_files,1); copyfile(old_files{i},new_files{i}); end; 
        end
        % map 3 (magnitude)
        % paths
        old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.fieldmaps(2))];
        new_path  = [dir_root,fs,'s',num2str(i_s),fs,dir_fm,fs,dir_funct,fs,dir_block,num2str(j)];
        % reorganise
        if exist(old_path,'dir')==7;
        fname     = spm_select('List', old_path, '^s.*\.nii$');
        old_files = cellstr([repmat([old_path fs],size(fname,1),1) fname]); 
        new_files = cellstr([repmat([new_path fs],size(fname,1),1) fname]); 
        for i = 1:size(old_files,1); copyfile(old_files{i},new_files{i}); end;
        end
    end
    
    %% delete field maps
    % maps 1-2
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.fieldmaps(1))];
    if exist(old_path,'dir')==7; rmdir(old_path,'s'); end
    % maps 3
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.fieldmaps(2))];
    if exist(old_path,'dir')==7; rmdir(old_path,'s'); end
        
    %% delete rest
    for k = 1:size(subj{i_s}.delete,2) 
    old_path  = [dir_root,fs,'s',num2str(i_s),fs,subj{i_s}.scanid,num2str(subj{i_s}.delete(k))];
    if exist(old_path,'dir')==7; rmdir(old_path,'s'); end;
    end
    
end

cd(cwd);
end