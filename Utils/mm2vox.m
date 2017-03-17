function vox_coords = mm2vox(V, mm_coords)
% function mm_coords = vox2mm(V, vox_coords)
%
% Utility to translate between mm and voxel coordinates (see also vox2mm)
% mm_coords - [x y z] array
% V - SPM image vol with .mat array
%
% SF 2015

temp = inv(V.mat) * [mm_coords 1]';
vox_coords = temp(1:3)';