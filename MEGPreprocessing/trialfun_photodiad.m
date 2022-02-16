function [trl, event] = trialfun_photodiad(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);
raw   = ft_read_data(cfg.dataset,'header',hdr);

% number of samples before and after
presamples  = cfg.trialdef.prestim*hdr.Fs;
postsamples = cfg.trialdef.poststim*hdr.Fs;

% identify when the photo-diad is on
PD = strcmp(hdr.label,cfg.trialdef.eventtype);
PD = raw(PD,:); % get photo-diad signal
PD = smooth(PD,hdr.Fs/100); % smooth by 10 ms
tmp = find(PD == 0); PD = PD(1:tmp(1)); % cut-off last part of zeros
PD = detrend(PD); % remove low frequency drift 

PD_on = PD < (mean(PD)-std(PD)); %get when the PD is on (when is less than 1 SD below mean)
PD_on_idx = find(PD_on);

% define trials based on this
nTrls       = cfg.trialdef.nTrls; 
trl         = [];

for t = 1:nTrls
    
    
    %get index of stim on for this trial
    on_idx = PD_on_idx(find(diff(PD_on_idx) > 1)+1); %indexes of each stim onset
    stimOn = on_idx(t); %get index for start of this trial's stim onset
    %get index of all samples from pre stim to trial end
    idx = stimOn - presamples:stimOn+postsamples; %get full indexes from prestim to end of trial

    % check if we're still within the data
    if idx(1) > PD_on_idx(end)
        fprintf('Reached the end of the data at trial %d \n',t)
        return;
    elseif idx(end) > PD_on_idx(end)
        idx = idx(idx < PD_on_idx(end));
        fprintf('Cutting trial %d short because of end data \n',t);
    elseif sum(PD_on(idx)) == 0
        fprintf('Reached the end of the data at trial %d \n',t)
        return;
    end
    
 
    % define trial samples
    trlbegin = round(stimOn - (cfg.trialdef.prestim*hdr.Fs)); % start 0.2 s before stim on 
    trlend   = round(stimOn + (cfg.trialdef.poststim*hdr.Fs)); %end 1s after stim on
    offset   = cfg.trialdef.prestim*hdr.Fs; %this represents where the stim comes on within the trial samples (i.e. the offset between trial start and stim start)
    newtrl   = [trlbegin trlend -offset];
    trl      = [trl; newtrl]; 
    
   
end


end

