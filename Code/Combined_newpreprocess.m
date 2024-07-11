% Define paths
set_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Converted_set_files/';
output_path = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Stay_upto_n&leave2/env1p32';
csv_file = '/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/Env2CSV_files/stay_data_p32_env2.csv';

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
    
    % Read the CSV file containing stay trials
    disp(['Reading CSV file: ' csv_file]);
    csv_data = readtable(csv_file);
    
    % Find the maximum number of stays for any tree
    stay_counts = groupcounts(csv_data, 'Tree_number');
    max_stays = max(stay_counts.GroupCount);
    disp(['Maximum number of stays across all trees: ' num2str(max_stays)]);
    
    % Loop through each stay number up to the maximum number of stays
    for stay_num = 1:max_stays
        disp(['Processing Stay ' num2str(stay_num)]);
        
        % Find the specific stay trials for the current stay number
        stays = [];
        unique_trees = unique(csv_data.Tree_number);
        for j = 1:length(unique_trees)
            tree_num = unique_trees(j);
            stay_idx = find(csv_data.Tree_number == tree_num, stay_num, 'first');
            if length(stay_idx) >= stay_num
                stays = [stays; stay_idx(stay_num)];
            end
        end
        
        % Print indices of the current stay trials for verification
        disp(['Indices of Stay ' num2str(stay_num) ' trials:']);
        disp(stays);
        
        % Preprocess the data
        disp('Preprocessing data...');
        
        % Set reference to FCz and rereference
        EEG = pop_chanedit(EEG, 'setref', {'1:31', 'FCz'});
        EEG = pop_reref(EEG, [29, 30], 'refloc', struct('labels', {'FCz'}, 'type', {''}, 'theta', {0.7867}, 'radius', {0.095376}, 'X', {27.39}, 'Y', {-0.3761}, 'Z', {88.668}, 'sph_theta', {-0.7867}, 'sph_phi', {72.8323}, 'sph_radius', {92.8028}, 'urchan', {31}, 'ref', {'FCz'}, 'datachan', {0}));
        EEG = pop_select(EEG, 'rmchannel', {'TP10', 'TP9'});
        
        % Plot after rereferencing
        reref_plot = pop_eegplot(EEG, 1, 1, 1);
        
        % Cleanline
        EEG = pop_cleanline(EEG, 'bandwidth', 2, 'chanlist', [1:EEG.nbchan], 'computepower', 1, 'linefreqs', [50], 'normSpectrum', 0, 'p', 0.01, 'pad', 2, 'plotfigures', 0, 'scanforlines', 1, 'sigtype', 'Channels', 'tau', 100, 'verb', 0, 'winsize', 4, 'winstep', 1);
        cleanline_plt = pop_eegplot(EEG, 1, 1, 1);
        
        % High and low-pass filtering
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5); % 0.5 Hz high-pass filter
        EEG = pop_eegfiltnew(EEG, 'hicutoff', 49); % 49 Hz low-pass filter
        original_chanlocs = EEG.chanlocs;
        filt_plot = pop_eegplot(EEG, 1, 1, 1);
        
        % Check event markers
        disp('Checking event markers...');
        disp(unique({EEG.event.type}));
        
        % Epoching and selecting the required trials
        if ismember('c', {EEG.event.type})
            EEG = pop_epoch(EEG, {'c'}, [-1 0], 'epochinfo', 'yes');
            EEG = pop_select(EEG, 'trial', stays);
            
            % Save the preprocessed dataset for the current stay
            preprocessed_filename = sprintf('preprocessed_%s_stay%d.set', set_file(1:end-4), stay_num);
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
                
                % Save the averaged dataset for the current stay
                avg_filename = sprintf('averaged_%s_stay%d.set', set_file(1:end-4), stay_num);
                avg_filepath = fullfile(output_path, avg_filename);
                try
                    pop_saveset(EEG_avg, 'filename', avg_filename, 'filepath', output_path);
                    disp(['Averaging complete and dataset saved: ' avg_filepath]);
                catch ME
                    disp(['Error saving the dataset for ' set_file ' stay' num2str(stay_num) ':']);
                    disp(ME.message);
                end
                
                % Update ALLEEG structure
                [ALLEEG, EEG_avg, CURRENTSET] = eeg_store(ALLEEG, EEG_avg, CURRENTSET);
                
                % Optionally, visualize the averaged dataset
                % pop_eegplot(EEG_avg, 1, 1, 1);
            else
                disp(['The dataset for ' set_file ' stay' num2str(stay_num) ' is not epoched.']);
            end
        else
            disp('The specified event marker ''c'' is not found in the dataset.');
        end
    end
catch ME
    disp(['Error processing file: ' set_file]);
    disp(ME.message);
end
