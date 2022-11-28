% Computes the changes between the value differences of two consecutive
% steps.

function change_diff = computeChangeInValueDifference(DataSamples)
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
% change_diff: [1 x n_samples] double
%   Difference between the value difference of two consecutive steps within
%   a trial.


% === Initialization === %

% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);
% Initialize output
change_diff = NaN(1, n_samples);
% Prepare value difference distribution
value_diff = DataSamples.value_left - DataSamples.value_right;

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

end