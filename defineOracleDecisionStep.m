% Returns the best decision step at each trial (step maximizing the value
% of control).

function decision_step = defineOracleDecisionStep(CueSamples, ...
    value_control)
% Parameters
% ----------
% CueSamples: structure
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Step index.
%   .cue_pos: [1 x n_samples] double
%       Position (1-4) of the sampled cue.
%   .cue_rank: [1 x n_samples] double
%       Rank (1-5) of the sampled cue.
% value_control: [1 x n_samples] double
%   Value of control of each sample (confidence - invested sampling
%   resources).
%
% Outputs
% -------
% decision_step: [1 x n_trials] int
%   For each trial, step at which the decision is taken and sampling stops.


% Get sampling information
n_trials = CueSamples.i_trial(end);

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
