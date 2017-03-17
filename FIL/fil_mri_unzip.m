function fil_mri_unzip(filename,subject);
% function fil_mri_unzip(filename,subject)
%
% Unzips the data from Charm, where filename is scan ID and subject is the
% subject number in the study (starting at 1).
%
% Note that this function only works on FIL computer as that is the only
% place where I store the zipped data (saving space).
%
% Steve Fleming & Dan Bang, FIL, 07/06/2016

% current directy
cwd = pwd;

% filesep
fs = filesep;

% add import tool
addpath(['C:',fs,'Users',fs,'dbang',fs,'Dropbox',fs,'Ego',fs,'Matlab',fs,'spm12',fs,'toolbox',fs,'Import_Archive']);

% unzip data in this folder
zipped   = ['C:',fs,'Users',fs,'dbang',fs,'Documents',fs,'MATLAB',fs,'brain_data',fs,'sensory_vs_decision',fs,'data_zipped',fs,filename];

% place unzipped data in this folder
unzipped = ['C:',fs,'Users',fs,'dbang',fs,'Dropbox',fs,'Ego',fs,'Matlab',fs,'ucl',fs,'sensory_vs_decision',fs,'brain',fs,'data',fs,'s',num2str(subject)];

% error if exist
if exist(unzipped,'dir'); error('--already unzipped'); else; mkdir(unzipped); end;

% error if not at the FIL
[~,name] = system('hostname');
if ~strcmp(name(1:end-1),'motorhead'); error('--only works at the FIL'); end;

% get folder names for unzipping
cd(zipped);
dirinfo = dir;

% loop through
for i = 3:size(dirinfo)
   Import_Archive(dirinfo(i).name,unzipped);
end

cd(cwd);

end