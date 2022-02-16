function dirInfo = get_dir_info(rootPath)

% Please organize your study according to the following folder structure.
% Have a look at the output of this function and organize your study
% accordingly. This will save a lot of time.

dirInfo = struct;

% Project root (e.g. /home/memspa/sanbos/_natcon/)
dirInfo.projectDir  = rootPath;

% Misc
dirInfo.adminDir    = fullfile(dirInfo.projectDir,'admin');
dirInfo.miscDir     = fullfile(dirInfo.projectDir,'misc');
dirInfo.tempDir     = fullfile(dirInfo.projectDir,'temp');
dirInfo.scriptsDir  = fullfile(dirInfo.projectDir,'scripts');

% Behavior
dirInfo.behDir      = fullfile(dirInfo.projectDir,'behavior');
dirInfo.logDir      = fullfile(dirInfo.behDir,'logs');
dirInfo.eyetrDir    = fullfile(dirInfo.behDir,'eyetracker');

% MRI
dirInfo.mriDir          = fullfile(dirInfo.projectDir,'mri');
dirInfo.mriRawDir       = fullfile(dirInfo.mriDir,'raw');
dirInfo.mriProcDir      = fullfile(dirInfo.mriDir,'processed');
dirInfo.mriRoiDir       = fullfile(dirInfo.projectDir,'rois');
dirInfo.mriTemplateDir  = fullfile(dirInfo.mriDir,'templates');

% MEG
dirInfo.megDir          = fullfile(dirInfo.projectDir,'meg');
dirInfo.megRawDir       = fullfile(dirInfo.megDir,'raw');
dirInfo.megProcDir      = fullfile(dirInfo.megDir,'processed');

% Task
dirInfo.taskDir     = fullfile(dirInfo.projectDir,'task');



end
