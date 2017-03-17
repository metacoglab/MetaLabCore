function check_warp(varargin)
% Modified spm_check_registration code to show results from preprocessing
% subjects easily in one panel
%
% SF 2014

fs = filesep;

% parse inputs
for i = 1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch lower(arg)
            case 'dir_base', dir_base = varargin{i+1};
            case 'dir_spm', spmdir = varargin{i+1};
            case 'subjects', name_subj = varargin{i+1};
        end
    end
end

dir_epi     = 'Functional';
dir_struct  = 'Structural';
dir_fm      = 'Fieldmaps';
sess_prfx   = 'sess';

addpath(spmdir);

conCat_files = [];
for n = 1:length(name_subj)
    
    imageDir = [dir_base fs name_subj{n} fs dir_epi fs sess_prfx '1'];
    f   = spm_select('List', imageDir, '^wuaf.*\.nii$');    % Select one of the normalised functional images; could alter to show warped structural
    image_file = [imageDir fs f(10,:)];
    conCat_files = [conCat_files; image_file];       % concatenate all files over runs
    
end
struct_file = [spmdir fs 'canonical/avg152T1.nii'];
spm_check_registration(conCat_files, struct_file);
