% Computes confidence at each sample approximated by estimating the amount
% of variance on value estimates at each trial step.

function confidence = computeBetaConfidenceDiff(value_diff, ...
    beta, i_step)
% Parameters
% ----------
% value_diff: [1 x n_samples] double
%   Difference in estimated values.
% beta: double
%   Linear coefficient linking variance on absolute value difference with
%   trial step.
% i_step: [1 x 1] or [1 x n_samples] double
%   Step within the ongoing trial.
%
% Outputs
% -------
% confidence: [1 x n_samples] double
%   Probability that the option being currently the best stays the best at
%   the end of trial.

% Variance of values only depends on the current step
variance = beta * (4 - i_step);

% Confidence depends on value estimates and standard deviation
confidence = VBA_sigmoid(...
    (pi * abs(value_diff)) ./ ...
    sqrt(3 * variance));

% On the fourth step, set confidence manually to avoid problems due to 0/0
confidence(i_step == 4) = 1;