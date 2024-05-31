function [onsets,offsets] = find_syllables(fname,segment_params,plot_flag)

%% Step 1: Extract putative syllable onsets/offsets %%%
%  output variables: ons_syls, offs_syls
       
    % Create smoothed sound vector with smoothing parameters:
    F_low = 1000.0; % highpass frequency (Hz)
    F_hi = 10000.0; % birdsong typically up to 10,000Hz
    sm_win = 1000*segment_params.sm_win; %smoothing window (msec), intentionally oversmooth
    
    % extract and smooth sound vector
    load(fname,'board_adc_data','frequency_parameters'); 
    sound_all = board_adc_data;
    Fs = frequency_parameters.amplifier_sample_rate;
    sm=evsmooth(sound_all,Fs,1,[],[],sm_win,F_low,F_hi); %smooth sound
    sm = sm*100; % scale up smoothed sound vector
    
    %% Extract putative syllable onsets/offsets w/ segmentation params:
    min_int = 1000*segment_params.min_int; %min gap between syllables in msec
    min_dur = 1000*segment_params.min_dur; %min syllable duration in msec
    syl_thresh = segment_params.threshold;

    % time transposed to seconds
    [ons_syls,offs_syls]=SegmentNotes(sm,Fs,min_int,min_dur,syl_thresh); 
    
    %% Plot smoothed sound vector and putative syllables
    % if plot_flag ==1
    %     figure; movegui('south');
    %     tvec = (0:numel(sound_all)-1)/Fs; %time vector is from 0-60sec
    %     plot(tvec,sm); hold on
    %     y_syl = repmat(syl_thresh,length(ons_syls),1);
    %     plot(ons_syls,y_syl,'*'); plot(offs_syls,y_syl,'*'); 
    %     ylim([0 0.2]);
    %     % xlim([0 60]);
    %     title([RemoveUnderScore(fname),' original onsets/offsets'])
    % end

%% 
%%% Step 2: Extract onsets/offsets of song syllables only %%%
%   Output variables: ons_songsyls, offs_songsyls

    % songbout parameters (in seconds)
    max_isi = 0.230; % syls within a songbout must be <max_isi sec apart
    window = 1.500; % window over which to count # of syl onsets
    syl_count = 4; % threshold # of syllable counts within window

    % create vector of inter-syllable intervals 
    isi_s =[];
    for ii = 1:length(ons_syls)-1
        isi_s(ii) = ons_syls(ii+1)-offs_syls(ii);
    end
        % figure; histogram(isi_s,"BinWidth",0.01) %in sec

    % Filtering by max_isi:
    % create new ons/offs selecting only for isi's < max_isi
    song_idx = find(isi_s < max_isi);
    ons_syls_isi = ons_syls(song_idx);
    offs_syls_isi = offs_syls(song_idx);

        % % visualize new onsets/offsets based on max_isi
        % if plot_flag
        %     hold on
        %     y_syl = repmat(syl_thresh+0.005,length(ons_syls_isi),1);
        %     plot(ons_syls_isi,y_syl,'*'); plot(offs_syls_isi,y_syl,'*'); 
        %     ylim([0 0.2]);
        %     % xlim([0 60]);
        %     title([RemoveUnderScore(fname),' original + new onsets/offsets'])
        % end

    % for each onset, calculate distance from all other onsets
    ons_dist = [];
    for j = 1:length(ons_syls_isi)
        ons_dist(:,j) = abs(ons_syls_isi(j)-ons_syls_isi);
    end

    % Filtering by syllable timing density:
    % for each onset, find the # of syllables that occur within a
    % window of time from that given syllable
    keep_gap = {};
    for k = 1:length(ons_syls_isi)
        keep_gap{1,k} = find(ons_dist(:,k)<window);
        keep_gap{2,k} = length(keep_gap{1,k});
    end

    % filter syllable ons/offs based on threshold # of onsets inside
    % window (highly likely to be song syllables)
    gaps = cell2mat(keep_gap(2,:));
    ons_songsyls = ons_syls_isi(gaps>syl_count);
    offs_songsyls = offs_syls_isi(gaps>syl_count);
        % visualize based on syllable timing density
        if plot_flag
        figure;
        tvec = (0:numel(sound_all)-1)/Fs; %time vector is from 0-60sec
        plot(tvec,sm); hold on
        y_syl = repmat(syl_thresh+0.01,length(ons_songsyls),1);
        plot(ons_songsyls,y_syl,'*');  
        ylim([0 .2]);
        end

%% 
%%% Step 3: Create '.not.mat' file %%%

savename = [fname '.not.mat'];
onsets = 1000*ons_syls; %use ons_syls for all vocalizations found
offsets = 1000*offs_syls; % use offs_syls for all vocalizations found
labels = char(repmat('-',1,length(onsets)));
threshold = syl_thresh;
min_int = min_int;
min_dur = min_dur;
save(savename, 'fname','Fs','labels','onsets','offsets','min_int','min_dur','threshold','sm_win')

end