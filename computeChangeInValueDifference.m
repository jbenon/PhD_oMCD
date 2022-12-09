% Computes the changes between the value differences of two consecutive
% steps.

function change_diff = computeChangeInValueDifference(DataSamples)
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
% change_diff: [1 x n_samples] double
%   Difference between the value difference of two consecutive steps within
%   a trial.




end