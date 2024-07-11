
x = EEG.data(20,:);    
y = EEG.data(4,:);  

% Calculate cross-correlation
[r, lags] = xcorr(x, y);

% Plot cross-correlation
figure;
plot(lags, r);
xlabel('Lag');
ylabel('Cross-Correlation');
title('Cross-Correlation between rAI and ACC');

% Optionally, you can normalize the cross-correlation by the auto-correlation
% of each sequence using 'coeff' option
[r_norm, lags_norm] = xcorr(x, y, 'coeff');

% Plot normalized cross-correlation
figure;
plot(lags_norm, r_norm);
xlabel('Lag');
ylabel('Normalized Cross-Correlation');
title('Normalized Cross-Correlation between rAI and ACC');
