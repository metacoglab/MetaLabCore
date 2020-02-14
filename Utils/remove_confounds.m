function [data] = remove_confounds(data, R, params)
% Remove confounds from timeseries with spm_dctmtx

%% Remove confounds

n = fix((2*(params.nscan*params.tr))./128); % define period of fastest cosine for HPF
dct = spm_dctmtx(params.nscan*params.nsess,n);
% Motion covariates and session mean
dct = [dct R];
data=data-dct*pinv(dct)*data;