% Returns an array storing which option was the best at the end of each
% samples trial.

function best_option = getTrialBestOption(DataSamples)
% Parameters
% ----------
% DataSamples: structure
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Trial index.
%   .value_left: [1 x n_samples] double
%       Estimated value of the left option.
%   .value_right: [1 x n_samples] double
%       Estimated value of the right option.
%
% Outputs
% -------
% best_option: [1 x n_trials] string
%   Stores which option was the best at the end of each trial: "left",
%   "right" or "both".


% Get samples dimensions
n_trials = DataSamples.i_trial(end);

% Initialize output
best_option = strings(1, n_trials);

% === Loop over trials === %
for i_trial = 1:n_trials
    % Define the index of the last sample of the trial
    i_sample = (i_trial - 1) * 4 + 4;
    % If both options are equal at the end of the trial
    if DataSamples.value_left(i_sample) == ...
            DataSamples.value_right(i_sample)
        best_option(i_trial) = "both";
    % If left option is the best at the end of the trial
    elseif DataSamples.value_left(i_sample) > ...
            DataSamples.value_right(i_sample)
        best_option(i_trial) = "left";
    % If right option is the best at the end of the trial
    else
        best_option(i_trial) = "right";
    end
end

end
