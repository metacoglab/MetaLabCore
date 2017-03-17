function totVol = maskVolume(img)
% Get volume of binary mask using SPM functions

if nargin <1 %no files
 img = spm_select(1,'image','Select mask volume');
end;

% read image
V = spm_vol(deblank(img));
i = spm_read_vols(V);
% get total nonzero voxels
result = sum(i(:) > 0);
% get voxel dimensions
prm = spm_imatrix(V.mat);
vs = prm(7:9);

voxVol = abs(vs(1)).*abs(vs(2)).*abs(vs(3));
totVol = (result.*voxVol)/1000;

fprintf('Mask %s volume is %f cm3 \n', img, totVol);