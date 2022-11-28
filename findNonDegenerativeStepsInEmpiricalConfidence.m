% Find samples which share option values together, but not confidence.

function sample_problem = findNonDegenerativeStepsInEmpiricalConfidence(...
    DataSamples, confidence)
% For samples sharing option values but not confidence, the precise
% confidence computation relies on the exact state of the system and not
% only option values.
%
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
% confidence: [1 x n_samples] double
%   Probability that the option being currently the best stays the best at
%   the end of trial.
%
% Output
% ------
% sample_problem: [1 x n_samples] bool
%   Indicate whether each sample is a non-degenerative sample for computing
%   confidence based on option values (1), or not (0).


% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);

% Initialize output
sample_problem = NaN(1, n_samples);

% === Loop over trials === %
for i_trial = 1:n_trials

    % === Loop over steps === %
    for i_step = 1:4
        % Define sample index
        i_sample = (i_trial - 1) * 4 + i_step;
        % Find samples with the same option values
        same_value = ...
            (DataSamples.value_left == DataSamples.value_left(i_sample)) & ...
            (DataSamples.value_right == DataSamples.value_right(i_sample));
        % Find samples with the same confidence
        same_confidence = (confidence == confidence(i_sample));
        % Find samples with the same step
        same_step = (DataSamples.i_step == i_step);
        % If this state can generate the same values but different
        % confidence, store it as a problem
        sample_problem(i_sample) = any(...
            same_value & same_step & (~ same_confidence));
    end
end

% Convert the array into logical array
sample_problem = logical(sample_problem);

end
