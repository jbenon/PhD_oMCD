% Computes the expected value of control at each sample, relative to future
% steps of the same trial, knowing the current value of control.

function w_exp_value_control = computeExpectedValueOfControl(CueSamples, ...
    value_control)
% At each step t, the expected value of control (EVC) is computed as:
% EVC(t) = mean(max(VC(t), EVC(t+1) | VC(t-1))
% Or:
% EVC(t) = w(t-1)
% w(t) = mean(max(VC(t+1), w(t+1)) | VC(t))
% It quantifies the value of control expected at step t if the optimal
% strategy is applied throughout the trials, knowing the precious value of
% control. Here, one computes w.
% Sampling must continue if VC(t) <= EVC(t+1), and stop otherwise.
%
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
% alpha: double
%   Cost of sampling during one more step.
%
% Outputs
% -------
% w_exp_value_control: [1 x n_samples] double
%   Value of control expected at the next step if the optimal strategy is
%   applied.


% Get sampling information
n_trials = CueSamples.i_trial(end);
n_samples = length(CueSamples.i_trial);

% Initialize expected value of control with low values
% (which are never selected in a max)
w_exp_value_control = - Inf * ones(1, n_samples);

% === Loop decreasing trial steps === %
for i_step = 3:-1:1
    % Select samples corresponding to the current step
    select_step = (CueSamples.i_step == i_step);

    % === Loop over trials === %
    for i_trial = 1:n_trials
        % Define the sample index
        i_sample = (i_trial - 1) * 4 + i_step;

        % === Select the value of control expected at the next step given
        % the current value of control === %

        % Select samples showing the same value control
        select_value_control = (value_control == value_control(i_sample));
        % Select samples right after the samples showing the same value
        % control at the same step
        select_next_samples = circshift(...
            (select_step & select_value_control), 1);
        % Select all the possible next value controls given the current
        % value control
        next_value_control = value_control(select_next_samples);

        % === Select the expected threshold w at the next step === %

        next_w_exp_value_control = w_exp_value_control(select_next_samples);

        % === Compute the threshold w at the current step === %

        w_exp_value_control(i_sample) = mean(...
            max(next_value_control, next_w_exp_value_control));

    end
end

end
