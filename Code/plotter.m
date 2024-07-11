% Define the paths to your CSV files
csv_file1 = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave2/aggregated_data_with_conditions_caudal.csv';
csv_file2 = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave/aggregated_data_with_conditions_2.csv';

% Load the CSV data for both files using readmatrix
data1 = readmatrix(csv_file1, 'Range', 2);  % Skip the header row and first column
data2 = readmatrix(csv_file2, 'Range', 2);  % Skip the header row and first column

% Check if the files are loaded correctly
if isempty(data1)
    error('Error loading data from %s', csv_file1);
end
if isempty(data2)
    error('Error loading data from %s', csv_file2);
end

% Calculate the average for each row in both datasets
average_activity1 = mean(data1(:, 2:end), 2);  % Calculate mean across columns for file 1
average_activity2 = mean(data2(:, 2:end), 2);  % Calculate mean across columns for file 2

% Define the conditions (row labels)
conditions = {'Stay 1', 'Stay 2', 'Stay 3', 'Stay 4', 'Stay 5', 'Stay 6', 'Leave'};

% Plotting
figure;
plot(1:length(conditions), average_activity1, '-o', 'LineWidth', 2, 'DisplayName', 'Environment 2');  % Plot for the first dataset
hold on;
plot(1:length(conditions), average_activity2, '-x', 'LineWidth', 2, 'DisplayName', 'Environment 1');  % Plot for the second dataset
hold off;

% Set x-axis tick labels and other plot properties
set(gca, 'XTick', 1:length(conditions), 'XTickLabel', conditions);  % Set x-axis tick labels
xlabel('Conditions');
ylabel('Average Activity');
title('Average Activity for Stay and Leave Conditions');
legend('show');  % Show legend
grid on;
