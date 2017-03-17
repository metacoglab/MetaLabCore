function mask_union(img1,img2,new_image_name)
% function mask_union(img1,img2,unionImg)
%
% Write out union of two images as new ROI
%
% Steve Fleming 2016

if nargin <1 %no files
 img1 = spm_select(1,'image','Select mask volume 1');
 img2 = spm_select(1,'image','Select mask volume 2');
end;

% read image
V1 = spm_vol(deblank(img1));
Vall(1) = V1;
V2 = spm_vol(deblank(img2));
Vall(2) = V2;

% Get image space from already existing ROI
Vo = V1;
Vo.fname = new_image_name;
spm_imcalc(Vall, Vo, 'i1 > 0 | i2 > 0');