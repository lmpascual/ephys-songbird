birdID= 'gy124wh97';
neuronID = 'day88';
syls = 'uiabcjk';
neural_channel = 8;
pre_onset_time_s = 0.2;
filelist = 'batch_passed_ch8_clust3.txt';

for i = 1:length(syls)
    currsyl = syls(i);
    % quantify_acoustics(currsyl,1,'mat')
    compile_case(birdID,neuronID,currsyl,neural_channel,pre_onset_time_s,filelist)
end
%% 
song_file = 'gy124wh97_220616_105115_songbout2.mat';
align_syl_num_all = 1;
which_trials = 'all';
trial_order = 'chron';
burstDetector = 0;

for ii = 1:length(syls)
    currsyl = syls(ii);
    motif_sumfile = ['gy124wh97_' currsyl '_day88_ch8_premotor_200ms_spiketimes_acoustics_2024-05-26.mat'];
    plot_multiple_FRs(song_file, motif_sumfile,align_syl_num_all,which_trials,trial_order, burstDetector)
end