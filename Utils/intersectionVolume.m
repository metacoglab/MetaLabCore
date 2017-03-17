function [i1_vol i2_vol int_vol] = intersectionVolume(img1,img2)
% function [i1_vol i2_vol int_vol] = intersectionVolume(img1,img2)
%
% Get volume of binary mask using SPM functions
%
% SF 2013

if nargin <1 %no files
 img1 = spm_select(1,'image','Select mask volume 1');
 img2 = spm_select(1,'image','Select mask volume 2');
end;

% read image
V1 = spm_vol(deblank(img1));
i1 = spm_read_vols(V1);
V2 = spm_vol(deblank(img2));
i2 = spm_read_vols(V2);
% get total nonzero voxels
i1_vol = sum(i1(:) > 0);
i2_vol = sum(i2(:) > 0);
int_vol = sum(i1(:) > 0 & i2(:) > 0);
% get voxel dimensions (assumes both images in same space)
prm = spm_imatrix(V1.mat);
vs = prm(7:9);

voxVol = abs(vs(1)).*abs(vs(2)).*abs(vs(3));
i1_vol = (i1_vol.*voxVol)/1000;
i2_vol = (i2_vol.*voxVol)/1000;
int_vol = (int_vol.*voxVol)/1000;

fprintf('Intersection volume is %f cm3 \n', int_vol);