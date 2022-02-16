function get_vars_from_struct(inputStruct)

fieldNames = fieldnames(inputStruct);
nFields    = length(fieldNames);

for iField = 1:nFields
    assignin('caller',fieldNames{iField},inputStruct.(fieldNames{iField}));
end
