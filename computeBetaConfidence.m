% Computes confidence at each sample approximated by estimating the amount
% of variance on value estimates at each trial step.

function confidence = computeBetaConfidence(DataSamples, beta)
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
%
% Outputs
% -------
% confidence: [1 x n_samples] double
%   Probability that the option being currently the best stays the best at
%   the end of trial.


% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);

% Define the standard deviation at step 0
std_0 = sqrt(var(abs(DataSamples.value_left(4:4:end) - ...
    DataSamples.value_right(4:4:end)), 1));

% Initialize confidence
confidence = NaN(1, n_samples);

% === Loop over trials === %
for i_trial = 1:n_trials

    % === Loop over trial steps === %
    for i_step = 1:4
        % Define sample index
        i_sample = (i_trial - 1) * 4 + i_step;
        % Standard deviation of values only depends on the current step
        standard_deviation = 1 / ((1 / std_0) + beta * i_step);
        if i_step < 4
            % Confidence depends on value estimates and standard deviation
            confidence(i_sample) = VBA_sigmoid(...
                (pi * abs(DataSamples.value_left(i_sample) - ...
                DataSamples.value_right(i_sample))) / ...
                sqrt(3 * standard_deviation));
        else
            % Confidence equals 1
            confidence(i_sample) = 1;
        end
    end
end

end