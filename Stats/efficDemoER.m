% EfficDemoER.m
% Runs simulation of design matrix, takes regressors as
% input to efficiency calcs

clear all
close all

% variables in msecs (change to see effects of e.g. SOA and D-M block length)
TR = 2600;
ntrials = 100;
trialLength = 4000;                    % Trial length in msecs=
binwidth = 100;                        % parameter for binning regressor data (msecs), default is TR/16 in SPM

trialLength_samples = round(trialLength/binwidth);
REG = [];

totalTime_samples = ntrials.*trialLength_samples;

%% ---------------------
% Simulate design matrix
% ----------------------
% Specify design matrix (1's every time there is a relevant event, zeros otherwise, here there is only two events e.g. stimulus+response as an example)
REG.event1 = zeros(totalTime_samples, 1);
REG.event2 = zeros(totalTime_samples, 1);
k = 1;
for i = 1:ntrials
    REG.event1(k) = 1;
    if rand > 0.5
        REG.event2(k) = 1;    % simulate an occasional response
    end
    k = k+trialLength_samples;
end

%% ------------------------
% Convolve DM with hrf
% -------------------------
RT = TR/1000; % convert to seconds
hrf = spm_hrf(RT);
hrf = resample(hrf, 1000, binwidth);    % Put in units of binwidth to match sample resolution

CON.event1 = conv(REG.event1,hrf);
CON.event2 = conv(REG.event2,hrf);

% Visualise regressors
plotnscans = 1:10*trialLength_samples; % pick out a few scans to plot
figure;
subplot(1,2,1)
plot(CON.event1(plotnscans),'r');
title('Event 1');
subplot(1,2,2)
plot(CON.event2(plotnscans),'b');
title('Event 2');

% Specify 1st level design matrix and contrast efficiency (note without
% orthogonalisation)
X =[CON.event1 CON.event2];
for j = 1:size(X,2)
    X(:,j)=X(:,j)-mean(X(:,j));     %mean corrects each
end
eff = 1./diag(inv(X'*X));         %calcs overall efficiency (not very meaningful)

contrast = [1 0; 0 1];   % contrast vectors of interest
for i = 1:size(contrast,1)
    eff_contrast(i) = 1/(contrast(i,:)*inv(X'*X)*contrast(i,:)'); % stores efficiency for defined contrast
end

% Visualise design matrix, plot efficiencies
figure;
clf
colormap gray
imagesc(X)      % Plot design matrix
title(sprintf('Efficiency for contrast [%d %d] = %0.3f',contrast(1), contrast(2), eff_contrast));

% data2plot(:,1) = eff_contrast(1:i/2)';
% data2plot(:,2) = eff_contrast((i/2+1):end)';
% figure;
% hist(data2plot);