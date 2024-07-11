% Add JIDT jar library to the path, and disable warnings that it's already there:
warning('off','MATLAB:Java:DuplicateClass');
javaaddpath('/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/infodynamics-dist-1/infodynamics.jar');
% Add utilities to the path
addpath('/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/infodynamics-dist-1/demos/octave');

% 0. Load/prepare the data:
data = load('/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/stay_upto_n&leave2/stay5/EEG_data_matrix.txt');
% Column indices start from 1 in Matlab:
source = octaveToJavaDoubleArray(data(:,20));
destination = octaveToJavaDoubleArray(data(:,4));

% 1. Construct the calculator:
calc = javaObject('infodynamics.measures.continuous.kraskov.TransferEntropyCalculatorKraskov');
% 2. Set any properties to non-default values:
calc.setProperty('k', '6');
calc.setProperty('NORM_TYPE', 'EUCLIDEAN_SQUARED');
calc.setProperty('AUTO_EMBED_RAGWITZ_NUM_NNS', '4');
% 3. Initialise the calculator for (re-)use:
calc.initialise();
% 4. Supply the sample data:
calc.setObservations(source, destination);
% 5. Compute the estimate:
result = calc.computeAverageLocalOfObservations();
% 6. Compute the (statistical significance via) null distribution empirically (e.g. with 100 permutations):
measDist = calc.computeSignificance(100);

fprintf('TE_Kraskov (KSG)(col_19 -> col_3) = %.4f nats (null: %.4f +/- %.4f std dev.; p(surrogate > measured)=%.5f from %d surrogates)\n', ...
	result, measDist.getMeanOfDistribution(), measDist.getStdOfDistribution(), measDist.pValue, 100);
