function nifti2analyze(nifti_image)
% Convert nifti to analyze image using spm tools
%
% Deletes original nifti file
%
% SF 2015

output_file=strrep(nifti_image,'.nii','.img');

Vin=spm_vol(nifti_image);
Vo=Vin;
Vo.fname=output_file;
Vo=spm_create_vol(Vo);
Data=spm_read_vols(Vin);
Vo=spm_write_vol(Vo,Data);

delete(nifti_image)