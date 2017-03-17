function ts = get_ROI_timecourse(maskImg, dir_images, R)
%% Extract out signal from series of images
%
% maskImg = mask file path
% dir_images = file path to functional images for this session
% R = matrix of covariates of no interest
%
% Steve Fleming 2016

fs = filesep;

% get image files for this session
f   = spm_select('List', dir_images, '^swauf.*\.nii$');     % Select smoothed normalised images
files  = cellstr([repmat([dir_images fs],size(f,1),1) f]);

% exclude motion regressors and constant terms
V = spm_vol(files);
Vmask = spm_vol(deblank(maskImg));
mask = spm_read_vols(Vmask);

if sum(V{1}.dim == Vmask.dim) ~= 3
   error('Mask and betas have different dimensions')
end
% get timecourse
for i = 1:length(scansToUse)
    img = spm_read_vols(V{i});
    dat = img(mask > 0);
    ts_uncorrected(i) = nanmean(dat(:));
end

% correct timeseries for confounds
params.nscan = [];  % FILL THIS IN WITH YOUR SCAN NUMBER, TR IN SECONDS
params.tr = [];
params.nsess = 1;
ts = remove_confounds(ts_uncorrected, R, params);