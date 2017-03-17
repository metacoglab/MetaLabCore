function analyze2nifti(analyze_image)
% Convert nifti to analyze image using spm tools
%
% Deletes original nifti file
%
% SF 2015

output_file=strrep(analyze_image,'.img','.nii');

Vin=spm_vol(analyze_image);
Vo=Vin;
Vo.fname=output_file;
Vo=spm_create_vol(Vo);
Data=spm_read_vols(Vin);
Vo=spm_write_vol(Vo,Data);

hdr_file = strrep(analyze_image,'.img','.hdr');
delete(analyze_image, hdr_file)