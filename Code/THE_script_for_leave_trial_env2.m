% Define paths
xdf_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/XDF_files/';
output_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Averaged4_files/';
csv_path_env2 = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Env2CSV_files/';

% Display the specified paths
disp(['XDF path: ' xdf_path]);
disp(['Output path: ' output_path]);

% List all files in the XDF directory
disp('Listing all files in the XDF directory:');
dir_contents = dir(xdf_path);
for k = 1:length(dir_contents)
    disp(dir_contents(k).name);
end

% Get list of all XDF files in the folder
xdf_files = dir(fullfile(xdf_path, '*.xdf'));

% Verify number of XDF files found
disp(['Number of XDF files found: ', num2str(length(xdf_files))]);

% Check if output path exists, if not create it
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

% Start EEGLAB
disp('Starting EEGLAB...');
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

for i = 1:length(xdf_files)
    try
        % Load the XDF file
        xdf_file = fullfile(xdf_files(i).folder, xdf_files(i).name);
        disp(['Loading file: ' xdf_file]);
        EEG = pop_loadxdf(xdf_file, 'streamtype', 'EEG', 'exclude_markerstreams', {});
        
        % Read the CSV file for environment 2 and count the number of 'leave' decisions
        csv_file_env2 = fullfile(csv_path_env2, [xdf_files(i).name(1:end-4), '.csv']);
        disp(['Reading CSV file: ' csv_file_env2]);
        csv_data_env2 = readtable(csv_file_env2);
        num_leave_trials_env2 = sum(strcmp(csv_data_env2.Decision, 'leave'));
        disp(['Number of leave trials in Env2: ', num2str(num_leave_trials_env2)]);
        
        % Preprocess the data
        disp('Preprocessing data...');
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5);
        EEG = pop_eegfiltnew(EEG, 'hicutoff', 50);
        EEG = pop_reref(EEG, []);
        EEG = pop_epoch(EEG, {'c'}, [0 1], 'epochinfo', 'yes');
        
        % Calculate the start and end trial indices for environment 2
        total_trials = EEG.trials;
        start_trial_env2 = total_trials - num_leave_trials_env2 + 1;
        end_trial_env2 = total_trials;
        
        % Select the trials corresponding to the 'leave' decisions in environment 2
        EEG = pop_select(EEG, 'trial', [start_trial_env2:end_trial_env2]);
        
        % Save the preprocessed dataset
        preprocessed_filename = sprintf('preprocessed_%s.set', xdf_files(i).name(1:end-4));
        preprocessed_filepath = fullfile(output_path, preprocessed_filename);
        pop_saveset(EEG, 'filename', preprocessed_filename, 'filepath', output_path);
        disp(['Preprocessed file saved: ' preprocessed_filepath]);

        % Compute the average across trials if the data is epoched
        if EEG.trials > 1
            disp('Averaging trials...');
            EEG_avg = EEG; % Create a copy of the dataset
            EEG_avg.data = mean(EEG.data, 3); % Average across the third dimension (trials)
            EEG_avg.trials = 1; % Update number of trials to 1
            EEG_avg.event = []; % Clear events (optional)
            EEG_avg.epoch = []; % Clear epochs (optional)
            EEG_avg.pnts = size(EEG_avg.data, 2); % Update number of points
            EEG_avg.xmin = EEG.xmin; % Copy xmin
            EEG_avg.xmax = EEG.xmax; % Copy xmax
            EEG_avg.times = EEG.times; % Copy times
            
            % Save the averaged dataset
            avg_filename = sprintf('averaged_%s.set', xdf_files(i).name(1:end-4));
            avg_filepath = fullfile(output_path, avg_filename);
            try
                pop_saveset(EEG_avg, 'filename', avg_filename, 'filepath', output_path);
                disp(['Averaging complete and dataset saved: ' avg_filepath]);
            catch ME
                disp(['Error saving the dataset for ' xdf_files(i).name ':']);
                disp(ME.message);
            end

            % Update ALLEEG structure
            [ALLEEG, EEG_avg, CURRENTSET] = eeg_store(ALLEEG, EEG_avg, CURRENTSET);

            % Optionally, visualize the averaged dataset
            % pop_eegplot(EEG_avg, 1, 1, 1);
        else
            disp(['The dataset for ' xdf_files(i).name ' is not epoched.']);
        end
    catch ME
        disp(['Error processing file: ' xdf_files(i).name]);
        disp(ME.message);
    end
end
