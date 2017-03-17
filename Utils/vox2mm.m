function mm_coords = vox2mm(V, vox_coords)
% function mm_coords = vox2mm(V, vox_coords)
%
% Utility to translate between mm and voxel coordinates (see also mm2vox)
% vox_coords - [x y z] array
% V - SPM image vol with .mat array
%
% SF 2015

temp = V.mat * [vox_coords 1]';
mm_coords = temp(1:3)';