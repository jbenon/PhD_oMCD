% Returns the decision step according to the EVC framework: stop when
% VC(t) <= EVC(t+1).

function decision_step = defineDecisionStep(value_control, ...
    w_exp_value_control)
% Parameters
% ----------
% value_control: [1 x n_samples] double
%   Value of control of each sample (confidence - invested sampling
%   resources).
% w_exp_value_control: [1 x n_samples] double
%   Value of control expected at the next step if the optimal strategy is
%   applied.
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
    % Find the first step when VC(t) >= EVC(t+1)
    decision_step(i_trial) = find(...
        value_control(i_samples_trial) >= ...
        w_exp_value_control(i_samples_trial), 1);
end
