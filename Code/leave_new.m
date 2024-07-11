% Define paths
set_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Converted_set_files/';
output_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave2/leave';
csv_file = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Env2CSV_files/P32_Gulafsa_Final_P32_001_24_9_22_.csv';

% Display the specified paths
disp(['SET path: ' set_path]);
disp(['Output path: ' output_path]);

% Specific SET file to process
set_file = 'P32_Gulafsa_Final_P32_001_24_9_22_.set';
set_fullfile = fullfile(set_path, set_file);
disp(['Processing SET file: ' set_fullfile]);

% Check if output path exists, if not create it
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

% Start EEGLAB
disp('Starting EEGLAB...');
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

try
    % Load the SET file
    disp(['Loading file: ' set_fullfile]);
    EEG = pop_loadset(set_fullfile);
    
    % Read the CSV file containing stay and leave decisions
    disp(['Reading CSV file: ' csv_file]);
    csv_data = readtable(csv_file);
    
    % Find leave trials
    leave_indices = find(strcmp(csv_data.Decision, 'leave'));
    
    % Print indices of leave trials for verification
    disp('Indices of leave trials:');
    disp(leave_indices);
    
    % Preprocess the data
    disp('Preprocessing data...');
    EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5);
    EEG = pop_eegfiltnew(EEG, 'hicutoff', 50);
    EEG = pop_reref(EEG, []);
    original_chanlocs = EEG.chanlocs;
    
    % Check event markers
    disp('Checking event markers...');
    disp(unique({EEG.event.type}));
    
    % Epoching and selecting the required trials
    if ismember('N', {EEG.event.type})
        EEG = pop_epoch(EEG, {'N'}, [-1 0], 'epochinfo', 'yes');
        
        % Filter only the leave trials
        valid_leave_trials = leave_indices(leave_indices <= EEG.trials);
        EEG = pop_select(EEG, 'trial', valid_leave_trials);
        
        % Save the preprocessed dataset
        preprocessed_filename = sprintf('preprocessed_%s_leave.set', set_file(1:end-4));
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
            avg_filename = sprintf('averaged_%s_leave.set', set_file(1:end-4));
            avg_filepath = fullfile(output_path, avg_filename);
            try
                pop_saveset(EEG_avg, 'filename', avg_filename, 'filepath', output_path);
                disp(['Averaging complete and dataset saved: ' avg_filepath]);
            catch ME
                disp(['Error saving the dataset for ' set_file ':']);
                disp(ME.message);
            end
            
            % Update ALLEEG structure
            [ALLEEG, EEG_avg, CURRENTSET] = eeg_store(ALLEEG, EEG_avg, CURRENTSET);
            
            % Optionally, visualize the averaged dataset
            % pop_eegplot(EEG_avg, 1, 1, 1);
        else
            disp(['The dataset for ' set_file ' does not have enough trials for leave.']);
        end
    else
        disp('The specified event marker ''N'' is not found in the dataset.');
    end
catch ME
    disp(['Error processing file: ' set_file]);
    disp(ME.message);
end
