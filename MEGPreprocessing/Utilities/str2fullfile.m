function outputFns = str2fullfile(rootDir,fileString)
% Searches for files in root directory that are in accordance with the file
% string (can include wildcard) and puts their full filenames in a cell
% array. If there is only one file that fulfills the critera, the output
% filename is supplied in a plain string instead of a cell array.
% 
% Usage: outputFns = str2fullfile('/sanbos/project/mri/','S01*.nii')


dirStruct = dir([rootDir filesep fileString]);

nFiles = size(dirStruct,1);

outputFns = cell(1,nFiles);

for iFile = 1:nFiles
    
    outputFns{iFile} = fullfile(fullfile(rootDir,dirStruct(iFile).name));
    
end

% % de-cell if only one file
% if nFiles == 1
%     outputFns = outputFns{1};
% end

