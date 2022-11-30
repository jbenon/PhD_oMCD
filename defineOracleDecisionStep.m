% Returns the best decision step at each trial (step maximizing the value
% of control).

function decision_step = defineOracleDecisionStep(value_control)
% Parameters
% ----------
% value_control: [1 x n_samples] double
%   Value of control of each sample (confidence - invested sampling
%   resources).
%
% Outputs
% -------
% decision_step: [1 x n_trials] int
%   For each trial, step at which the decision is taken and sampling stops.


% Get sampling information
n_trials = length(value_control) / 4;

% Initialize output
decision_step = NaN(1, n_trials);

% === Loop over trials === %
for i_trial = 1:n_trials
    % Define the trial indices
    i_start_trial = (i_trial - 1) * 4 + 1;
    i_samples_trial = i_start_trial:(i_start_trial + 3);
    % Find the step where the value of control is the highest
    [~, stop_step] = max(value_control(i_samples_trial));
    % Store the information
    decision_step(i_trial) = stop_step;
end
