function binarize_image(img, new_image_name)
% Utility to binarize image file
%
% SF 2015

if nargin <1 %no files
 img = spm_select(1,'image','Select mask volume');
 new_image_name = input('New image name? ', 's');
end;

% read image
V = spm_vol(deblank(img));
Vo = V;
Vo.fname = new_image_name;
spm_imcalc(V, Vo, 'i1 > 0');