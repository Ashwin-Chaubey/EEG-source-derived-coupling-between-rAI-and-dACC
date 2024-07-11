% Check if EEG data is loaded
if exist('EEG', 'var')
    % Extract the EEG data matrix
    data_matrix = EEG.data;
    
    % Check if the data matrix is 3D, and reshape it to 2D if needed
    % This assumes that the third dimension represents trials
    if ndims(data_matrix) == 3
        % Reshape to 2D (channels x (points * trials))
        data_matrix = reshape(data_matrix, size(data_matrix, 1), []);
    end
    
    % Define the output CSV file name
    csv_file_name = 'EEG_data_matrix.csv';
    
    % Save the data matrix to a CSV file
    disp(['Saving data matrix to CSV file: ' csv_file_name]);
    csvwrite(csv_file_name, data_matrix);
    
    disp(['Data matrix successfully saved to: ' csv_file_name]);
else
    disp('EEG data not loaded. Please load the dataset first.');
end
