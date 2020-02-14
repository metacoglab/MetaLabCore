function [conv_hrf, xtime] = visualize_hrf(spec, onsetTime, duration, makeplots)
% Generate upsampled and convolved canonical HRF for visualisation
%
% Requires spm_hrf to be in the path
%
% INPUTS
%
% spec.TR = TR in seconds
% spec.samp_reso = sample resolution in seconds e.g. 0.1
%
% onsetTime = onset time of regressor in seconds
% duration = duration of regressor in seconds
%
% makeplots = 1 or 0 for plot or no plots
%
% OUTPUTS
%
% conv_hrf = convolved oversampled HRF
% xtime = time in seconds of each bin
%
% Steve Fleming 2017
% stephen.fleming@ucl.ac.uk

spec.samp_rate     = spec.samp_reso./spec.TR;    % sample rate in fractions of a TR

[TR_hrf p] = spm_hrf(spec.TR);

% Oversample this by same amount at specified sample rate (where
% samp_rate is 1/number of samples per TR)
t      = 0:length(TR_hrf)-1;
t_ups  = 0:spec.samp_rate:length(TR_hrf)-1;
ts_ups = spline(t,TR_hrf,t_ups);    % interpolates time series
xtime = [1:length(ts_ups)].*spec.samp_reso;  % this should be same for all subjects

% Convolve with regressor
integerOnset = dsearchn(xtime', onsetTime);
integerDuration = duration./spec.samp_reso;
regressor = zeros(1,length(xtime));
regressor(integerOnset:integerOnset+integerDuration) = 1;
conv_hrf = conv(ts_ups, regressor);

% Plot
if makeplots
    figure;
    plot(xtime, conv_hrf(1:length(xtime)), 'LineWidth', 2);
    hold on
    plot(xtime, regressor)
    legend('BOLD', 'regressor')
    xlabel('Time (s)')
    ylabel('Expected HRF')
    set(gca, 'FontSize', 16)
    box off
    legend boxoff
end
