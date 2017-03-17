function make_ROI(roiName, roiCoord, sphereSize, base_img, outputDir)
% function make_ROI(roiName, roiCoord, sphereSize, base_img)
%
% Write spherical ROIs
%
% SF 2015

cwd = pwd;

fs = filesep;

% Get image space from already existing ROI
Vbase = spm_vol(deblank(base_img));

% Write out sphere at these coordinates
xY.def  = 'sphere';
xY.xyz  = roiCoord';
xY.spec = sphereSize;
Vsphere = struct(...
    'fname',   [outputDir fs roiName '.nii'],...
    'dim',     Vbase.dim,...
    'dt',      [spm_type('uint8') spm_platform('bigend')],...
    'mat',     Vbase.mat,...
    'pinfo',   [1 0 0]',...
    'descrip', 'ROI');
Vsphere = spm_create_vol(Vsphere);

temp = false(Vbase.dim);    % make base image
[~,~,k] = spm_ROI(xY,Vsphere); % get indices of sphere
temp(k) = true; % set to 1
cd(outputDir);
spm_write_vol(Vsphere,temp);
cd(cwd);
