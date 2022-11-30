% Computes the estimated value at the next time step using a variation
% of gamma on the value of the current step.

function [next_value] = predictNextGammaValues(value, gamma, n_simu)
% Parameters
% ----------
% value: [1 x 1] or [1 x n_simu] double
%   Estimated value an option. 
% gamma: double
%   Linear coefficient capturing how much the absolute value difference
%   changes across time.
% n_simu: double
%   Number of times the prediction of the next value is repeated.
%
% Outputs
% -------
% next_value: [1 x n_simu] double
%   Predicted value of an option at the next step, based on its current
% estimated value.


% Estimate values at the next step
next_value = value + sqrt(gamma) * randn(1, n_simu);

end
