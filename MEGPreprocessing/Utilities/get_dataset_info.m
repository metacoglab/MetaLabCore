function datasetInfo = get_dataset_info(datasetIDs,projectName,projectVersion)


%% Load datasetDetails from text file

datasetDetailsFileName      = sprintf('datasetDetails_%s_%d.txt',projectName,projectVersion);

% The following line can lead to errors: Pleas make sure that your are in
% current project dir, containig the txt file with that datasetDetails
[mFilePath,~,~]             = fileparts(mfilename('fullpath'));

fid                         = fopen([mFilePath filesep datasetDetailsFileName]);
datasetDetails              = textscan(fid,'%s %d %d %d %d %*[^\n]');
fclose(fid);

% Dataset IDs have 3 characters, like 'S01'
nDatasetIDChars             = 3;


%% Easy option 'all' for including all aqcuired datasets

if strncmp(datasetIDs,'all',nDatasetIDChars)
    datasetIDs = cellfun(@(x) x(1:nDatasetIDChars), datasetDetails{1}, 'UniformOutput',false)';
end


%%

% Reset final output structure
datasetInfo = struct;

nDatasets = length(datasetIDs);

for iDataset = 1:nDatasets
    
    datasetID                   = char(datasetIDs{iDataset});
    subjectNumbers(iDataset)    = str2double(datasetID(2:3));
    
    datasetDetailsLogical = strncmp(datasetDetails{1},datasetIDs{iDataset},nDatasetIDChars);
    
    datasetInfo(iDataset).datasetName = ...
        datasetDetails{1}{datasetDetailsLogical};
    
    datasetInfo(iDataset).epiRuns = ...
        [datasetDetails{2}(datasetDetailsLogical) ...
        datasetDetails{3}(datasetDetailsLogical) ...
        datasetDetails{4}(datasetDetailsLogical) ...
        datasetDetails{5}(datasetDetailsLogical)];
end
