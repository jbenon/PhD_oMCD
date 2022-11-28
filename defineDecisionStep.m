% Returns the decision step according to the EVC framework: stop when
% VC(t) <= EVC(t+1).

function decision_step = defineDecisionStep(CueSamples, ...
    value_control, w_exp_value_control)
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
% w_exp_value_control: [1 x n_samples] double
%   Value of control expected at the next step if the optimal strategy is
%   applied.
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
    % Find steps when VC(t) > EVC(t+1)
    stop_steps = find(value_control(i_samples_trial) > ...
        w_exp_value_control(i_samples_trial));
    % Stop on the first step found
    decision_step(i_trial) = min(stop_steps);
end
