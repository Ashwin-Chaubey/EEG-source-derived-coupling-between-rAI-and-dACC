% Define the path to your CSV file
csv_file = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave2/leave/EEG_data_matrix.csv';
txt_file = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave2/leave/EEG_data_matrix.txt';

% Load the CSV data using readtable to handle headers
data_table = readtable(csv_file);

% Remove the first column
%data_table(:, 1) = [];

% Convert the table to an array
data = table2array(data_table);

% Transpose the data
data = data';

% Open a file for writing
fileID = fopen(txt_file, 'w');

% Check if the file opened successfully
if fileID == -1
    error('Could not open file for writing.');
end

% Write the data to the TXT file
for i = 1:size(data, 1)
    fprintf(fileID, '%f\t', data(i, :));
    fprintf(fileID, '\n');
end

% Close the file
fclose(fileID);

disp(['Data successfully written to ', txt_file]);
