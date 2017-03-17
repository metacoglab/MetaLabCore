function data_quality(varargin)
% function data_quality(['path', 'path/to/data'], ['subjects', subjects], ['data', data])
% Data quality check script

% parse inputs
for i = 1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch lower(arg)
            case 'path', dir_base = varargin{i+1};
            case 'subjects', name_subj = varargin{i+1};
            case 'data', epi_dir_raw = varargin{i+1};
        end
    end
end

cwd = pwd;
fs = filesep;
for s0 = 1:length(name_subj)
    
    for i = 1:length(epi_dir_raw)

        scanDir = [dir_base fs name_subj{s0} fs epi_dir_raw{i}];
        fname   = spm_select('List', scanDir, '^sub.*\.nii$');
        
        cd(scanDir)
        roiCorners(fname, 'roi.txt');
        dataQReport(fname, 'roi.txt');
        cd(pwd);
    end
end