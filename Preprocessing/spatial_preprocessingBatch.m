function spatial_preprocessingBatch(varargin)
% function spatial_preprocessingBatch(['dir_base', dir_base], ['subjects', subjects], ['n_sess', n_sess], ...)
% Spatial Preprocessing for fMRI data
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script 
% a) Realigns & unwarps using preprocessed fieldmaps,
% b) Coregisters the structural to mean-epi generated in (a)
% c) Segments the coregistered structural
% d) Normalizes all functional runs using forward deformations generated in
% (c)
% OR normalises structural to MNI template and applies warp to functional
% runs
% e) Smooths functional images
%
% Requires subject and session specific subdirs, each with their own
% EPI, fieldmap and structural subdirectories.
% 
% INPUTS - string/value pairs
% 'dir_base' - path to data
% 'dir_spm' - path to SPM
% 'subjects' - cell array of subject codes
% 'n_sess' - number of functional runs
% 'slicetiming' - 1/0, default = 0
% 'realign' - 1/0, default = 1
% 'coregister' - 1/0, default = 1
% 'segment' - 1/0, default = 1
% 'normalise' - 1/0, default = 1 (requires segmentation parameters from previous step)
% 'old_normalise' - 1/0, default = 0 (switch off if using unified segmentation)
% 'smoothing' - 1/0, default = 1
% 'FWHM' - FWHM of smoothing kernel, default = 8
% 'resolEPI' - resolution of EPI data, default = [2 2 2]
% 'nslices' - number of slices in EPI scan
% 'TR' - TR in seconds
% 'sliceorder' - order of slices e.g. for interleaved acquisition [2:2:nslices 1:2:nslices-1]
%
% All default values taken from SPM12 batch unless specified
%
% Steve Fleming 2008 - 2015 stephen.fleming@ucl.ac.uk
% Adapted in part from Christian Kaul's, Christian Doeller's and Hanneke Den
% Ouden's code
% _________________________________________________________________________

%% Define subject parameters and directories
fs = filesep;

% Set defaults (overridden by inputs below)
slicetiming = 1;
realign = 1;
coregister = 1;
segment = 1;
normalise = 1;
old_normalise = 0;
smoothing = 1;
FWHM = 8;
resolEPI = [2 2 2];

% parse inputs
for i = 1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch lower(arg)
            case 'dir_base', dir_base = varargin{i+1};
            case 'dir_spm', spmdir = varargin{i+1};
            case 'subjects', name_subj = varargin{i+1};
            case 'n_sess', n_sess = varargin{i+1};
            case 'slicetiming', slicetiming = varargin{i+1};
            case 'realign', realign = varargin{i+1};
            case 'coregister', coregister = varargin{i+1};
            case 'segment', segment = varargin{i+1};
            case 'normalise', normalise = varargin{i+1};
            case 'old_normalise', old_normalise = varargin{i+1};
            case 'smoothing', smoothing = varargin{i+1};
            case 'fwhm', FWHM = varargin{i+1};
            case 'resolepi', resolEPI = varargin{i+1};
            case 'nslices', nslices = varargin{i+1};
            case 'tr', TR = varargin{i+1};
            case 'sliceorder', sliceorder = varargin{i+1};
        end
    end
end

dir_epi     = 'Functional';
dir_struct  = 'Structural';
dir_fm      = 'Fieldmaps';
sess_prfx   = 'sess';

addpath(spmdir);

%%%%%%%%%%%%%%%%%%%%%%%

%% Slice-timing
if slicetiming
    for s0 = 1 : length(name_subj)
        disp(['Slice timing job specification for Subject : ', name_subj{s0}]);
        clear matlabbatch
        
        % cd to functional dir so that the .mat and .ps file is written there for future
        % review
        cd([dir_base fs name_subj{s0} fs dir_epi]);
        % loop to define new session in job
        for sess = 1:n_sess
            % define epi files in the session
            scanDir = [dir_base fs name_subj{s0} fs dir_epi fs sess_prfx num2str(sess)];
            % select scans and assign to job
            f   = spm_select('List', scanDir, '^f.*\.nii$');
            files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
            matlabbatch{1}.spm.temporal.st.scans(sess) = {files}; 
            % clear temporary variables for next run
            f = []; files = [];
        end
        matlabbatch{1}.spm.temporal.st.nslices = nslices;
        matlabbatch{1}.spm.temporal.st.tr = TR;
        matlabbatch{1}.spm.temporal.st.ta = TR - (TR/nslices);
        matlabbatch{1}.spm.temporal.st.so = sliceorder;
        matlabbatch{1}.spm.temporal.st.refslice = round(nslices/2);
        matlabbatch{1}.spm.temporal.st.prefix = 'a';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save and run job
        save slicetiming.mat matlabbatch
        disp(['RUNNING slice timing correction for subject ' name_subj{s0}]);
        spm_jobman('run','slicetiming.mat');
        clear matlabbatch
    end
end

%% Realignment and unwarping
if realign
    disp(['Realign: Realignment & UnWarp for MEAN and ALL images ']);
    for s0 = 1 : length(name_subj)
        disp(['Realign job specification for Subject : ', name_subj{s0}]);
        
        % cd to functional dir so that the .mat and .ps file is written there for future
        % review
        cd([dir_base fs name_subj{s0} fs dir_epi]);
        % loop to define new session in job
        for sess = 1:n_sess
            % define epi files in the session
            scanDir = [dir_base fs name_subj{s0} fs dir_epi fs sess_prfx num2str(sess)];
            % select scans and assign to job
            f   = spm_select('List', scanDir, '^af.*\.nii$');
            files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
            jobs{1}.spatial{1}.realignunwarp.data(sess).scans = files;
            % clear temporary variables for next run
            f = []; files = [];
            % select fieldmap aligned to first epi in this session, add to
            % structure
            dir_fmap = fullfile(dir_base, name_subj{s0}, dir_fm, [sess_prfx num2str(sess)]);
            vdmfilefilter = sprintf('^%s.*%s.nii$','vdm5',fs);
            vdmfilename = spm_select('List', dir_fmap, vdmfilefilter);
            vdmfilename = fullfile(dir_fmap,vdmfilename);
            jobs{1}.spatial{1}.realignunwarp.data(sess).pmscan{1} = vdmfilename;   % Note address the cell first with {}, then the structure with (), then put in cell...
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % specify Estimation Options
        
        jobs{1}.spatial{1}.realignunwarp.eoptions.quality = 1;      % default 0.9
        jobs{1}.spatial{1}.realignunwarp.eoptions.sep     = 4.0;
        jobs{1}.spatial{1}.realignunwarp.eoptions.fwhm    = 5.0;
        jobs{1}.spatial{1}.realignunwarp.eoptions.rtm     = 0;
        jobs{1}.spatial{1}.realignunwarp.eoptions.einterp = 7;      % default 2, changed to 7
        jobs{1}.spatial{1}.realignunwarp.eoptions.ewrap    = [0 0 0];
        jobs{1}.spatial{1}.realignunwarp.eoptions.weight  = {};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        jobs{1}.spatial{1}.realignunwarp.uweoptions.basfcn   = [12 12];
        jobs{1}.spatial{1}.realignunwarp.uweoptions.regorder = 1.0;
        jobs{1}.spatial{1}.realignunwarp.uweoptions.lambda   = 1e+005;
        jobs{1}.spatial{1}.realignunwarp.uweoptions.jm       = 0;
        jobs{1}.spatial{1}.realignunwarp.uweoptions.fot      = [4 5];
        jobs{1}.spatial{1}.realignunwarp.uweoptions.sot      = [];
        jobs{1}.spatial{1}.realignunwarp.uweoptions.uwfwhm   = 4;
        jobs{1}.spatial{1}.realignunwarp.uweoptions.rem      = 1;
        jobs{1}.spatial{1}.realignunwarp.uweoptions.noi      = 5;
        jobs{1}.spatial{1}.realignunwarp.uweoptions.expround = 'Average';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % specify Reslice Options
        jobs{1}.spatial{1}.realignunwarp.uwroptions.uwwhich   = [2 1];
        jobs{1}.spatial{1}.realignunwarp.uwroptions.rinterp  = 7;     % default 4, changed to 7
        jobs{1}.spatial{1}.realignunwarp.uwroptions.wrap    = [0 0 0];
        jobs{1}.spatial{1}.realignunwarp.uwroptions.mask    = 1.0;
        jobs{1}.spatial{1}.realignunwarp.uwroptions.prefix    = 'u';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save and run job
        save realignunwarp.mat jobs
        disp(['RUNNING Realign for subject ' name_subj{s0}]);
        spm_jobman('run','realignunwarp.mat');
        disp('Job completed');
        clear jobs
    end
end

%% Coregister
if coregister
    % =========================================================================
    % =========================================================================
    % in this case we only want to coregister the structural to the mean
    % epi from the first run
    disp(['Coregister: Estimate structural (change postition file (.hdr) to match postition of epi-mean file)']);
    for s0 = 1 : length(name_subj)
        disp(['Coregister job specification for Subject : ', name_subj{s0}]);
        % cd so that .mat and .ps files are written in functional dir
        cd([dir_base fs name_subj{s0} fs dir_epi]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % first specify the mean epi image from first run
        sourceDir = [dir_base fs name_subj{s0} fs dir_epi fs sess_prfx '1'];
        f  = spm_select('List', sourceDir, '^meanuaf.*\.nii$');
        files = [sourceDir fs f];
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = {files};   % select mean epi as reference
        f = []; files = [];
        % then specify structural ref image
        stDir = [dir_base fs name_subj{s0} fs dir_struct];
        f   = spm_select('List', stDir, '^s.*\.nii$');
        stFile = [stDir fs f];
        matlabbatch{1}.spm.spatial.coreg.estimate.source = {stFile};   % select strutural as source
        stFile = [];
        matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [ 0.0200 0.0200 0.0200 0.0010 0.0010 0.0010 ...
            0.0100 0.0100 0.0100 0.0010 0.0010 0.0010];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save and run job
        save coreg_structural.mat matlabbatch
        disp(['RUNNING Coreg for subject ' name_subj{s0}]);
        spm_jobman('run','coreg_structural.mat');
        clear matlabbatch
    end
end

%% Unified segmentation (new segment)
if segment
    % =========================================================================
    % =========================================================================
    disp(['Segmentation: Produce gray matter (native & modulated normalized) & white matter (native) from structural image ']);
    for s0 = 1 : length(name_subj)
       
        cd([dir_base fs name_subj{s0} fs dir_epi]);
        disp(['Segmentation job specification for Subject : ', name_subj{s0}]);
        stDir = [dir_base fs name_subj{s0} fs dir_struct];
        f   = spm_select('List', stDir, '^s.*\.nii$'); % notice coreg only changed header .mat file, so same address
        stFile = {[stDir fs f]};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        jobs{1}.spatial{1}.preproc.channel.vols = stFile;
        jobs{1}.spatial{1}.preproc.channel.biasreg = 1e-03;
        jobs{1}.spatial{1}.preproc.channel.biasfwhm = 60;
        jobs{1}.spatial{1}.preproc.channel.write = [1 0];   % save bias-corrected image
        
        % Tissue priors
        jobs{1}.spatial{1}.preproc.tissue(1).tpm{1} = [spmdir fs 'tpm/TPM.nii,1'];
        jobs{1}.spatial{1}.preproc.tissue(1).ngaus = 1;
        jobs{1}.spatial{1}.preproc.tissue(1).native = [1 0];
        jobs{1}.spatial{1}.preproc.tissue(1).warped = [0 0];
        jobs{1}.spatial{1}.preproc.tissue(2).tpm{1} = [spmdir fs 'tpm/TPM.nii,2'];
        jobs{1}.spatial{1}.preproc.tissue(2).ngaus = 1;
        jobs{1}.spatial{1}.preproc.tissue(2).native = [1 0];
        jobs{1}.spatial{1}.preproc.tissue(2).warped = [0 0];
        jobs{1}.spatial{1}.preproc.tissue(3).tpm{1} = [spmdir fs 'tpm/TPM.nii,3'];
        jobs{1}.spatial{1}.preproc.tissue(3).ngaus = 2;
        jobs{1}.spatial{1}.preproc.tissue(3).native = [1 0];
        jobs{1}.spatial{1}.preproc.tissue(3).warped = [0 0];
        jobs{1}.spatial{1}.preproc.tissue(4).tpm{1} = [spmdir fs 'tpm/TPM.nii,4'];
        jobs{1}.spatial{1}.preproc.tissue(4).ngaus = 3;
        jobs{1}.spatial{1}.preproc.tissue(4).native = [1 0];
        jobs{1}.spatial{1}.preproc.tissue(4).warped = [0 0];
        jobs{1}.spatial{1}.preproc.tissue(5).tpm{1} = [spmdir fs 'tpm/TPM.nii,5'];
        jobs{1}.spatial{1}.preproc.tissue(5).ngaus = 4;
        jobs{1}.spatial{1}.preproc.tissue(5).native = [1 0];
        jobs{1}.spatial{1}.preproc.tissue(5).warped = [0 0];
        jobs{1}.spatial{1}.preproc.tissue(6).tpm{1} = [spmdir fs 'tpm/TPM.nii,6'];
        jobs{1}.spatial{1}.preproc.tissue(6).ngaus = 2;
        jobs{1}.spatial{1}.preproc.tissue(6).native = [1 0];
        jobs{1}.spatial{1}.preproc.tissue(6).warped = [0 0];
        
        % Warp options
        jobs{1}.spatial{1}.preproc.warp.mrf = 1;
        jobs{1}.spatial{1}.preproc.warp.cleanup = 1;
        jobs{1}.spatial{1}.preproc.warp.reg = [0 1e-03 0.5 0.05 0.2];
        jobs{1}.spatial{1}.preproc.warp.affreg = 'mni';
        jobs{1}.spatial{1}.preproc.warp.fwhm = 0;
        jobs{1}.spatial{1}.preproc.warp.samp = 3;
        jobs{1}.spatial{1}.preproc.warp.write = [1 1];  % write out inverse + forward deformations

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save and run job
        save segment.mat jobs
        disp(['RUNNING Segmentation for subject ' name_subj{s0}]);
        spm_jobman('run','segment.mat');
        clear jobs
    end
end

%% Normalise bias-correct structural and slicetime corrected EPIs
if normalise
    
    % =========================================================================
    % =========================================================================
    % here we load the normalization parameter file produced during
    % segmentation and normalize T1 image with it (to calc mean structural
    % later)
    disp(['Normalizing ... ']);
    for s0 = 1 : length(name_subj)
        
        % cd so that .mat and .ps files are written in functional dir
        cd([dir_base fs name_subj{s0} fs dir_epi]);
        disp(['Normalization job specification for Subject : ', name_subj{s0}]);
        stDir = [dir_base fs name_subj{s0} fs dir_struct];
        
        conCat_files = [];
        % Loop over sessions for epi's
        for sess = 1:n_sess
            scanDir = [dir_base fs name_subj{s0} fs dir_epi fs sess_prfx num2str(sess)];
            % select unwarped
            f   = spm_select('List', scanDir, '^uaf.*\.nii$');
            files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
            conCat_files = [conCat_files; files];       % concatenate all files over runs
            f = []; files = [];
        end
        
        % Directly warp EPI for subset of subjects if e.g. no structural
        % available
        if old_normalise
            
            f   = spm_select('List', stDir, '^s.*\.nii$');
            matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {[stDir fs f]};
            matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = conCat_files;
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 1e-04;
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = [spmdir fs 'tpm/TPM.nii'];
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 1e-03 0.5 0.05 0.2];
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
            matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
            matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb       = [-78 -112 -70; 78 76 85]; % bounding box of volume
            matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox      = resolEPI;  % voxel size of normalised images; DEFAULT = 2x2x2
            matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp   = 7; 
            
            % save and run job
            save normwriteEPI.mat matlabbatch
        else
            
            % normalise EPI: write
            % *********************************************************************
            % select forward deformation images from T1 segmentation step
            f   = spm_select('List', stDir, '^y_.*\.nii$');
            files  = {[stDir fs f]};
            jobs{1}.spatial{1}.normalise{1}.write.subj.def      = files;
            f = []; files = [];
            
            jobs{1}.spatial{1}.normalise{1}.write.subj.resample     = conCat_files;
            jobs{1}.spatial{1}.normalise{1}.write.woptions.bb       = [-78 -112 -70; 78 76 85]; % bounding box of volume
            jobs{1}.spatial{1}.normalise{1}.write.woptions.vox      = resolEPI;  % voxel size of normalised images; DEFAULT = 2x2x2 (CHANGED to acquisition resolution)
            
            jobs{1}.spatial{1}.normalise{1}.write.woptions.interp   = 7;        % changed default to 7th degree B-spline
            % save and run job
            save normwriteEPI.mat jobs
            
        end
        

        disp(['RUNNING normalisation (write) job for subject ' name_subj{s0}])
        v
        clear jobs
        % *********************************************************************
    end
end


%% Smoothing
if smoothing
    disp(['Smoothing... ']);
    for s0 = 1 : length(name_subj)
        disp(['Smoothing job specification for Subject : ', name_subj{s0}]);
        % smoothing
        % *********************************************************************
        % cd so that .mat and .ps files are written in functional dir
        cd([dir_base fs name_subj{s0} fs dir_epi]);
        % get normalized scans
        conCat_files = [];
        for sess = 1:n_sess
            scanDir = [dir_base fs name_subj{s0} fs dir_epi fs sess_prfx num2str(sess)];
            f   = spm_select('List', scanDir, '^wuaf.*\.nii$');
            files  = cellstr([repmat([scanDir fs],size(f,1),1) f]);
            conCat_files = [conCat_files; files];       % concatenate all files over runs
            f = []; files = [];
        end
        
        jobs{1}.spatial{1}.smooth.data                          = conCat_files;
        jobs{1}.spatial{1}.smooth.fwhm                          = [FWHM FWHM FWHM];
        jobs{1}.spatial{1}.smooth.dtype                         = 0; 
        
        % save and run job
        save smooth.mat jobs
        disp(['RUNNING normalisation (smoothing) job for subject ' name_subj{s0}])
        spm_jobman('run','smooth.mat');
        clear jobs;
        % *********************************************************************
    end
end


