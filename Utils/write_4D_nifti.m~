function write_4D_nifti(images, outDir, prefix)
% function write_4D_nifti(images, outDir, prefix)
%
% Writes a 4D nifti from a series of 3D input files
% Needs SPM functions to work.
% images - char array of 3D images to combine
 
cwd = pwd;
if (nargin < 1)
    [images,sts] = spm_select;
    if (sts == 0)
        fprintf('write_4D_nifti: Operation cancelled.\n');
        return;
    end
end
 
for j=1:size(input_imgs,1)