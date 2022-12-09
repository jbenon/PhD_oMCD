% Computes the coefficient Beta apporximating the precision on value
% estimate at each step.

function [f_gamma, gamma] = computeDifferenceApproximationGamma(...
    DataSamples)
% Parameters
% ----------
% DataSamples: structure
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Step index.
%   .value_left: [1 x n_samples] double
%       Estimated value of the left option.
%   .value_right: [1 x n_samples] double
%       Estimated value of the right option.
%
% Outputs
% -------
% gamma: double
%   Coefficient capturing how much the absolute value difference changes
%   across time.


% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);
% Initialize storage of changes in value differences
change_diff = NaN(1, n_samples);
% Compute value difference distribution
value_diff = DataSamples.value_left - DataSamples.value_right;

% === Compute change in value difference between consecutive steps === %

% Compute the difference between step 0 (no difference between options) and
% step 1
change_diff(1:4:end) = value_diff(1:4:end);

% === Loop over remaining steps === %
for i_step = 2:4
    % Select samples of the desired step
    i_samples = ((1:n_trials) - 1) * 4 + i_step;
    % Select samples of the previous step
    i_samples_prev = i_samples - 1;
    % Store the difference between absolute value differences of the two
    % steps
    change_diff(i_step:4:end) = value_diff(i_samples) - ...
        value_diff(i_samples_prev);
end

% === Compute gamma === %

gamma = var(change_diff, 1) / 2;

% === Plot === %

f_gamma = figure("Position", [50, 50, 1000, 400]);
% Plot value differences
subplot(1, 2, 1);
plot(reshape(value_diff, 4, []), "o-", "Color", [0, 0, 0, 0.008]);
xticks(1:4);
xlabel("Step");
ylabel("V_{left} - V_{right}");
% Plot histogram of changes in value differences
subplot(1, 2, 2);
histogram(change_diff, "Normalization", "probability");
hold on;
xline(mean(change_diff), "r-", "LineWidth", 2);
xline(mean(change_diff) + sqrt(var(change_diff, 1)), ...
    "r--", "LineWidth", 1.5);
xline(mean(change_diff) - sqrt(var(change_diff, 1)), ...
    "r--", "LineWidth", 1.5);
text(0.3, 0.17, sprintf("Gamma = %0.4f", gamma), "Color", "r", ...
    "HorizontalAlignment", "center");
xlabel("Change in V_{left} - V_{right}")

end
