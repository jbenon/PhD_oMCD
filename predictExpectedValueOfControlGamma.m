% Computes the expected value of control at each sample, relative to future
% steps of the same trial, knowing the current value of control.

function w_exp_value_control = predictExpectedValueOfControlGamma(...
    value_left, value_right, alpha, beta, gamma)
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
% value_left: [1 x n_samples] double
%   Estimated value of the left option.
% value_right: [1 x n_samples] double
%   Estimated value of the right option.
% alpha: double
%   Coefficient controlling the cost of each unit of time invested into
%   sampling.
% beta: double
%   Linear coefficient linking variance on the absolute difference between
%   estimated values with trial step.
% gamma: double
%   Linear coefficient capturing how much the absolute value difference
%   changes across time.
%
% Outputs
% -------
% w_exp_value_control: [1 x n_samples] double
%   Value of control expected at the next step if the optimal strategy is
%   applied.


% Get sampling information
n_samples = length(value_left);
n_trials = n_samples / 4;
all_i_step = repmat(1:4, 1, n_trials);

% Initialize expected value of control at the last step of each trial
w_exp_value_control = (0.5 - alpha * 4) * ones(1, n_samples);

% Compute current value of control
confidence = computeBetaConfidence(value_left, value_right, beta, ...
    all_i_step);
value_control = confidence - alpha * all_i_step;

% Define the number of random drawings for Gamma approximation
fact_simu_gamma = 100;

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
        % Compute the number of simulations to make
        n_simu_gamma = sum(select_next_samples) * fact_simu_gamma;
        % Simulate possible next values of control
        next_value_control = computeBetaConfidence(...
            predictNextGammaValues(value_left(i_sample), gamma, n_simu_gamma), ...
            predictNextGammaValues(value_right(i_sample), gamma, n_simu_gamma), ...
            beta, i_step + 1) - alpha * (i_step + 1);
        
        % === Compute the threshold === %

        % Select the predicted threshold w at the next step
        next_w_exp_value_control = w_exp_value_control(select_next_samples);
        % Do multiple comparisons to include variations in the specifically
        % considered sample and variation in gamma approximation
        next_w_exp_value_control = repmat(...
            next_w_exp_value_control, 1, fact_simu_gamma);
        % Compute the threshold w at the current step
        w_exp_value_control(i_sample) = mean(...
            max(next_value_control, next_w_exp_value_control));
    end
end

end
