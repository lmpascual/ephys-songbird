% Define the source and destination directories
sourceDir = 'J:\br177yw112\br177yw112_221213_091449\song\221214\';
destinationDir = 'C:\Users\LPASCU2\OneDrive - Emory University\SongbirdProject\Data\recording files\br177yw112_day79\';

% Open the file containing the list of file names
cd(sourceDir)
fileID = fopen('batch_passed_files_ch4.txt','r');

% Read the entire file, assuming each line contains a file name
fileList = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

% fileList{1} contains the list of file names
for i = 1:length(fileList{1})
    % Construct the full source path for the current file
    sourceFile = [sourceDir, fileList{1}{i}];
    
    % Construct the full destination path for the current file
    destinationFile = [destinationDir, fileList{1}{i}];
    
    % Copy the file from source to destination
    copyStatus = copyfile(sourceFile, destinationFile);
    
    % Check if the file was successfully copied
    % if copyStatus == 1
    %     fprintf('Successfully copied %s\n', fileList{1}{i});
    % else
    %     fprintf('Failed to copy %s\n', fileList{1}{i});
    % end
end
