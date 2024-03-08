function [spectrograms_matrix,labels_all,days_all] = compileSylSpects(savedir,output_filename,spect_params)
%   Original write date: Dec 2023
%   Author: Leila May Pascual

% Initialize feature matrix
spectrograms_binlength_shortest = [];
labels_all = [];
days_all = [];
labels_by_day = {};
spectrograms_full_syl_durations = {};
raw_audio = {};
failedSyls ={};

% print spect parameters
spect_params
birdname = spect_params.birdname;
syls = spect_params.syls;
days = spect_params.days_folder_id;

% Concatenate spectrograms, syllable labels, and days
for d= 1:length(days)
    day = days(d)
    % change to folder containing files
    [~, ~,~,directory,~] = raster_params(birdname,day);
    cd(directory)

    spect_day = [];
    labels_day = [];
    spect_uncut_day=[];
    raw_audio_day = {};
    try
    [spect_day, labels_day,spect_uncut_day, raw_audio_day] = getSpectMatrix(syls, spect_params);
    [spectrograms_binlength_shortest] = [spectrograms_binlength_shortest; spect_day];
    [labels_all] = [labels_all, labels_day];
    [days_all] = [days_all; repmat(day,size(spect_day,1),1)];
    spectrograms_full_syl_durations{d} = spect_uncut_day;
    labels_by_day{d} = labels_day;
    raw_audio = [raw_audio;raw_audio_day];

    catch exception
        message = ['failed for: ' num2str(day) ' -syl ' syls];
        failedSyls = [failedSyls; message];
        disp(message)
    end

end

% Replace values at indices 661 and 662 with 66
days_all(days_all == 661 | days_all == 662) = 66;
days(days == 661 | days == 662) = 66;
days_all(days_all == 801 | days_all ==802 | days_all ==803) = 80;
days(days ==801 | days ==802 | days==803) = 80;
days_all(days_all == 811 | days_all ==812) = 81;
days(days ==811 | days ==812) = 81;

%% Save output to processed data folder
dateGenerated = char(datetime("today","Format","uuuu-MMM-dd"));
cd(savedir)
save(output_filename,"birdname","syls","days","spectrograms_binlength_shortest","labels_by_day",...
    "labels_all","days_all","spectrograms_full_syl_durations", "raw_audio", "spect_params",...
    "dateGenerated","failedSyls",'-v7.3' )

if spect_params.set_bin_length == "shortest"
    spectrograms_matrix = spectrograms_binlength_shortest;

elseif spect_params.set_bin_length == "longest"
    % zero pad spectrograms shorter than the longest syllable duration
    spectrograms_binlength_longest = spectsZeroPad(spectrograms_full_syl_durations);
    spectrograms_matrix = spectrograms_binlength_longest;
    save(filename,"spectrograms_binlength_longest", '-append');
end