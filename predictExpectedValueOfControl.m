% Computes the expected value of control at each sample, relative to future
% steps of the same trial, knowing the current value of control.

function w_exp_value_control = predictExpectedValueOfControl(...
    confidence, alpha)
% At each step t, the expected value of control (EVC) is computed as:
% EVC(t) = mean(max(VC(t), EVC(t+1) | VC(t-1))
% Or:
% EVC(t) = w(t-1)
% w(t) = mean(max(VC(t+1), w(t+1)) | VC(t))
% It quantifies the value of control expected at step t if the optimal
% strategy is applied throughout the trials, knowing the previous value of
% control. Here, one computes w.
% Sampling must continue if VC(t) <= EVC(t+1), and stop otherwise.
%
% Parameters
% ----------
% confidence: [1 x n_samples] double
%   Probability that the option being currently the best stays the best at
%   the end of trial.
% alpha: double
%   Coefficient controlling the cost of each unit of time invested into
%   sampling.
%
% Outputs
% -------
% w_exp_value_control: [1 x n_samples] double
%   Value of control expected at the next step if the optimal strategy is
%   applied.


% Get sampling information
n_samples = length(confidence);
n_trials = n_samples / 4;
all_i_step = repmat(1:4, 1, n_trials);

% Initialize expected value of control at the last step of each trial
w_exp_value_control = (0.5 - alpha * 4) * ones(1, n_samples);

% Compute current value of control
value_control = confidence - alpha * all_i_step;

% === Loop decreasing trial steps === %
for i_step = 3:-1:1
    % Select samples corresponding to the current step
    select_step = (all_i_step == i_step);

    % === Loop over trials === %
    for i_trial = 1:n_trials
        % Define the sample index
        i_sample = (i_trial - 1) * 4 + i_step;

        % === Estimate next possible values of control === %

        % Select samples showing the same value control
        select_value_control = (value_control == value_control(i_sample));
        % Select next samples
        select_next_samples = circshift(...
            (select_step & select_value_control), 1);
        % Select next possible values of control
        next_value_control = value_control(select_next_samples);
        
        % === Compute the threshold === %

        % Select the predicted threshold w at the next step
        next_w_exp_value_control = w_exp_value_control(select_next_samples);
        % Compute the threshold w at the current step
        w_exp_value_control(i_sample) = mean(...
            max(next_value_control, next_w_exp_value_control));

    end
end

end
