% Define the main path
main_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave2';

% Define sub-folder names and the order
folders = {'stay1', 'stay2', 'stay3', 'stay4', 'stay5', 'stay6', 'leave'};
conditions = {'Stay 1', 'Stay 2', 'Stay 3', 'Stay 4', 'Stay 5', 'Stay 6', 'Leave'};

% Initialize an empty array to store the data
data_matrix = [];

% Loop through each folder
for i = 1:length(folders)
    % Define the full path to the CSV file
    csv_file = fullfile(main_path, folders{i}, 'EEG_data_matrix.csv');
    
    % Read the CSV file
    data = csvread(csv_file);
    
    % Extract row 54 (adjust for MATLAB 1-based indexing)
    row_data = data(4, :);
    
    % Add the row data to the data matrix
    data_matrix = [data_matrix; row_data];
end

% Add a column to represent the conditions
conditions_col = (1:length(folders))';
data_matrix_with_conditions = [conditions_col, data_matrix];

% Convert the numeric condition labels to the actual condition names
condition_labels = repmat({''}, size(data_matrix_with_conditions, 1), 1);
for i = 1:length(conditions)
    condition_labels{i} = conditions{i};
end

% Create a table with the condition labels and the data matrix
T = array2table(data_matrix_with_conditions(:, 2:end), 'VariableNames', arrayfun(@(x) sprintf('Sample_%d', x), 1:size(data_matrix, 2), 'UniformOutput', false));
T.Conditions = condition_labels;

% Move the 'Conditions' column to the front
T = movevars(T, 'Conditions', 'Before', 1);

% Display the table
disp(T);

% Optionally, save the table to a new CSV file
writetable(T, fullfile(main_path, 'aggregated_data_with_conditions_caudal.csv'));
