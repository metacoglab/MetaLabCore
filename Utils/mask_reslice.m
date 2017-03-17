function mask_reslice(filename, mask)
% function mask_reslice(filename, mask)
% Reslice mask into same space as image file e.g. structural
%
% SF 2015

f = filename;
matlabbatch{1}.spm.spatial.coreg.write.ref = {f(1,:)};
matlabbatch{1}.spm.spatial.coreg.write.source{1} = mask;
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
save reslice.mat matlabbatch
disp(['Reslicing masks'])
spm_jobman('run','reslice.mat');
delete('reslice.mat')