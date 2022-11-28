% Computes confidence at each sample approximated by estimating the amount
% of variance on value estimates and the absolute value difference at each
% time step.

function [abs_diff_value, confidence] = computeBetaGammaConfidence(...
    DataSamples, beta, gamma)
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
% beta: double
%   Linear coefficient linking precision on value estimated with trial
%   step.
% gamma: double
%   Linear coefficient capturing how much the absolute value difference
%   changes across time.
%
% Outputs
% -------
% abs_diff_value: [1 x _sample] double
%   Absolute difference in option values approximated from the step of the
%   trial.
% confidence: [1 x n_samples] double
%   Probability that the option being currently the best stays the best at
%   the end of trial.


% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);

% Define value estimate at step 0
value_0 = rankToProbability(3) * rankToMagnitude(3);

% Define the standard deviation at step 0
std_0 = sqrt(var(abs(DataSamples.value_left(4:4:end) - ...
    DataSamples.value_right(4:4:end)), 1));

% Initialize output
value_left = NaN(1, n_samples);
value_right = NaN(1, n_samples);
abs_diff_value = NaN(1, n_samples);
confidence = NaN(1, n_samples);

% === Loop over trials === %
for i_trial = 1:n_trials

    % === Loop over trial steps === %
    for i_step = 1:4
        % Define sample index
        i_sample = (i_trial - 1) * 4 + i_step;

        % === Estimate absolute value difference === %

        % After step 1, vary the value estimates of the previous step
        if i_step > 1
            value_left(i_sample) = value_left(i_sample - 1) + ...
                sqrt(gamma) * randn();
            value_right(i_sample) = value_right(i_sample - 1) + ...
                sqrt(gamma) * randn();
        % At step 1, vary the value estimates of the step 0
        else
            value_left(i_sample) = value_0 + sqrt(gamma) * randn();
            value_right(i_sample) = value_0 + sqrt(gamma) * randn();
        end
        % Compute the absolute value difference
        abs_diff_value(i_sample) = abs(value_left(i_sample) - ...
            value_right(i_sample));

        % === Estimate variation on the absolute value difference === %

        standard_deviation = 1 / ((1 / std_0) + beta * i_step);

        % === Compute confidence === %

        if i_step < 4
            % Confidence depends on value estimates and standard deviation
            confidence(i_sample) = VBA_sigmoid(...
                (pi * abs_diff_value(i_sample)) / ...
                sqrt(3 * standard_deviation));
        else
            % Confidence equals 1 at the last step
            confidence(i_sample) = 1;
        end
    end
end

end
