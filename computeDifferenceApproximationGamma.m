% Computes the coefficient Beta apporximating the precision on value
% estimate at each step.

function [gamma] = computeDifferenceApproximationGamma(...
    DataSamples)
% Parameters
% ----------
% DataSamples: structure
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Step index.
%   .value_left: [1 x n_samples] double
%       Estimated value of the left option.
%   .value_right: [1 x n_samples] double
%       Estimated value of the right option.
%
% Outputs
% -------
% gamma: double
%   Coefficient capturing how much the absolute value difference changes
%   across time.


% Compute the change in value difference between consecutive steps of a
% trial
change_diff = computeChangeInValueDifference(DataSamples);

% Compute gamma
gamma = var(change_diff, 1) / 2;

end
