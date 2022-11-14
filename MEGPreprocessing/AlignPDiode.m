function dataMain = AlignPDiode(cfg0,data)

    cfg = [];
    cfg.channel = cfg0.trialdef.pdiodetype ;
    lightDiodeSignal = ft_preprocessing(cfg, data);
   
    % determine the onset of the visual stimulus
    visOnset = [];
    for iTrial = 1:length(lightDiodeSignal.trial)
        PD_on = lightDiodeSignal.trial{iTrial} < (mean(lightDiodeSignal.trial{iTrial})-std(lightDiodeSignal.trial{iTrial})); %get when the PD is on (when is less than 1 SD below mean)
        PD_on_idx = find(PD_on);   
        visOnset(iTrial) = lightDiodeSignal.time{iTrial}(PD_on_idx(1));
    end
    
    %figure;
    %scatter(1:length(visOnset),visOnset)
    
    figure;
    for i = 1:length(lightDiodeSignal.time)
        
        plot(lightDiodeSignal.time{i},lightDiodeSignal.trial{i})
        hold on
    end
    xline(0,'r')
    title('Unaligned Trials')

    % realign the trials to this onset
    cfg = [];
    cfg.offset = -visOnset * data.fsample;
    dataMain = ft_redefinetrial(cfg, data);

    %cut segments of interest
    cfg =[];
    cfg.toilim = [-cfg0.prestim cfg0.poststim];
    dataMain = ft_redefinetrial(cfg,dataMain);

    
    %plot New redefined trials
    cfg = [];
    cfg.channel = cfg0.trialdef.pdiodetype ;
    lightDiodeSignal = ft_preprocessing(cfg, dataMain);
    
    figure;
    for i = 1:length(lightDiodeSignal.time)
        plot(lightDiodeSignal.time{i},lightDiodeSignal.trial{i})
        hold on
    end
    xline(0,'r')
    title('Aligned Trials')
end