% Returns the value of control at the time of decision for each trial.

function decision_value_control = getDecisionValueOfControl(...
    decision_step, value_control)
% Parameters
% ----------
% decision_step: [1 x n_trials] int
%   For each trial, step at which the decision is taken and sampling stops.
% value_control: [1 x n_samples] double
%   Value of control of each sample (confidence - invested sampling
%   resources).
%
% Outputs
% -------
% decision_value_control: [1 x n_trials] double
%   Value of control at the time of the decision.


% Get sample dimensions
n_trials = length(decision_step);

% Define the index of the decision sample at each trial
i_decision_sample = ((1:n_trials) - 1) * 4 + decision_step;

% Get the value of control at each decision sample
decision_value_control = value_control(i_decision_sample);

end
