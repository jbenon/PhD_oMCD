% Computes the coefficient Beta approximating the variance on the absolute
% difference between estimated values at each time step.

function [f_beta, beta] = computeVarianceApproximationBeta(CueSamples, ...
    DataSamples)
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
% f_beta: figure
%   Plot of the linear model used to compute beta.
% beta: double
%   Linear coefficient linking variance on the absolute difference between
%   estimated values with trial step.


% Get samples dimensions
n_trials = CueSamples.i_trial(end);
n_samples = length(CueSamples.i_trial);

% === Compute precision === %

% Get samples internal states
states = getSamplesInternalStates(CueSamples);
% Compute the variance of |V_left - V_right| at each step
variance = computeValueDifferenceVariance(DataSamples, states);

% === Compute beta === %

% Create the vector of predictors (steps from horizon)
time_steps = repmat(3:-1:0, 1, n_trials);
% Run a linear regression without intercept
mdl = fitlm(time_steps', variance', ...
    "linear", "Intercept", false, ...
    "VarNames", ...
    ["Steps from horizon (4-t)", "Variance on |V_left - V_right|"]);
% Extract the beta
beta = mdl.Coefficients.Estimate(1);

% === Plot regression === %

f_beta = figure;
plot(mdl);
xticks(0:4);
text(1.5, 500, sprintf("Beta = %0.4f", beta), ...
    "Color", "r", "HorizontalAlignment", "center");


end
