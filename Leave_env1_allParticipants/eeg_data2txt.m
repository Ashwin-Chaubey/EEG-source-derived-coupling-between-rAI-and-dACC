% Define the path and filename for the output .txt file
outputFile = 'EEG_stay2.txt'; % You can update the filename and path as needed

% Extract the data from the EEG structure
data = EEG.data;

% Transpose the data so that each column represents an ROI
data = data';

% Open a file for writing
fid = fopen(outputFile, 'w');

% Check if the file opened successfully
if fid == -1
    error('Cannot open the file for writing: %s', outputFile);
end

% Get the size of the transposed data
[timepoints, channels] = size(data);

% Write the data to the file
for i = 1:timepoints
    fprintf(fid, '%f\t', data(i, :)); % Write each timepoint's data on a new line, separated by tabs
    fprintf(fid, '\n');
end

% Close the file
fclose(fid);

fprintf('Data successfully written to %s\n', outputFile);
