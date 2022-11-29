% Computes the variance of the absolute difference between estimated
% values, depending on the number of attributes sampled.

function variance = computeValueDifferenceVariance(DataSamples, ...
    states)
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
% states: [4 x n_samples] double
%   Each column describes the state of a sample: the known rank of the left
%   probability, left magnitude, right probability and left magnitude. The
%   unknown attributes are replaced with NaN.
%
% Outputs
% -------
% variance: [1 x n_samples] double
%   Variance of the absolute difference between option values.


% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);

% Initialize output
variance = NaN(1, n_samples);

% Replaces the NaN by 0 to enable comparison between internal states
states(isnan(states)) = 0;

% === Loop over trials === %
for i_trial = 1:n_trials

    % === Loop over trial steps === %
    for i_step = 1:4
        % Define sample index
        i_sample = (i_trial - 1) * 4 + i_step;
        % Find samples with the same state
        select_samples = all((states == states(:, i_sample)));
        % Select trials containing the same state
        select_trials = DataSamples.i_trial(select_samples);
        % Select the last step of trials containing the same state
        select_final_step = select_trials * 4;
        % Get the distribution of absolute value difference
        abs_value_diff = abs(DataSamples.value_left(select_final_step) - ...
            DataSamples.value_right(select_final_step));
        % Compute the variance of the distribution
        variance(i_sample) = var(abs_value_diff, 1);
    end
end

end