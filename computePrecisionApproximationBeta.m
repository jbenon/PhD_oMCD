% Computes the coefficient Beta approximating the precision on value
% estimate at each step.

function [f_beta, beta] = computePrecisionApproximationBeta(CueSamples, ...
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
%   Linear coefficient linking precision on value estimated with trial
%   step.


% Get samples dimensions
n_trials = CueSamples.i_trial(end);
n_samples = length(CueSamples.i_trial);

% === Compute precision === %

% Get samples internal states
states = getSamplesInternalStates(CueSamples);
% Compute the precision of |V_left - V_right| at each step
precision = computeValueEstimatePrecision(DataSamples, states);

% === Constrain the precision before the trial starts === %

% Precision when nothing is known
precision_0 = 1 / var(abs(DataSamples.value_left(4:4:end) - ...
    DataSamples.value_right(4:4:end)), 1);
% Initialize the enhanced vector of precision
precision_constrained = NaN(1, n_samples * (5/4));
% === Loop over trials === %
i_start_constrain = 1;
for i_trial = 1:n_trials
    % Define indices of trial start and end
    i_start_trial = (i_trial - 1) * 4 + 1;
    i_end_trial = (i_trial - 1) * 4 + 4;
    % Insert the precision at step 0
    precision_constrained(i_start_constrain:(i_start_constrain + 4)) = ...
        [precision_0, precision(i_start_trial:i_end_trial)];
    i_start_constrain = i_start_constrain + 5;
end
% Shift the precision vector to have no intercept for the regression
precision_constrained = precision_constrained - precision_0;

% === Compute beta === %

% Create the enhanced vector of predictors (including step 0)
time_steps = repmat(0:4, 1, n_trials);
% Run a linear regression without intercept
mdl = fitlm(time_steps', precision_constrained', ...
    "linear", "Intercept", false, ...
    "VarNames", ...
    ["Steps", "Precision on |V_left - V_right| (centered at step 0)"]);
% Extract the beta
beta = mdl.Coefficients.Estimate(1);

% === Plot regression === %

f_beta = figure;
plot(mdl);
xticks(0:4);
text(1.5, 500, sprintf("Beta = %0.4f", beta), ...
    "Color", "r", "HorizontalAlignment", "center");


end
