% Computes the benefit of stopping at time T, then the expected optimal
% benefit at time T-1, then recursively the expected optimal benefit at all
% times t < T-1, depending on the difference of values.

function [all_value_diff, exp_optimal_benefit] = predictOptimalBenefit(...
    alpha, beta, gamma)
% Parameters
% ----------
% alpha: double
%   Effort parameter.
% beta: double
%   Linear coefficient linking variance on the difference between
%   estimated values with trial step.
% gamma: double
%   Coefficient capturing how much the value difference changes across
%   time.
%
% Outputs
% -------
% all_value_diff: [1 x n_value_diff] double
%   All considered possible value differences.
% exp_optimal_benefit: [T x n_value_diff] double
%   Optimal benefit expected at time t regarding t + 1, for all possible
%   value differences.


% === Initialization === %

% Define the temporal horizon
T = 4;
% Define the range of considered value differences
all_value_diff = -2:0.001:2;
n_value_diff = length(all_value_diff);
% Initialize the storrage of expected optimal benefits
exp_optimal_benefit = NaN(T, n_value_diff);

% === Step T-1 === %

% Compute the (deterministic) benefit of stopping at step T
exp_optimal_benefit(T, :) = (1 - alpha * T) * ones(1, n_value_diff);
% Compute the benefit of stopping at step T - 1
current_benefit_stop = computeBetaConfidenceDiff(all_value_diff, ...
    beta, T - 1) - alpha * (T - 1);
% Compute the expected optimal benefit at step T
exp_optimal_benefit(T - 1, :) = max(...
    current_benefit_stop, exp_optimal_benefit(T, :));

% === Steps t < T-1 === %

for i_step = (T-2):-1:1
    % Compute the benefit of stopping at the next step
    next_benefit_stop = computeBetaConfidenceDiff(all_value_diff, ...
        beta, i_step + 1) - alpha * (i_step + 1);
    % Compute the expected optimal benefit at the next step given the value
    % difference observed at the next step
    next_exp_benefit = max(next_benefit_stop, ...
        exp_optimal_benefit(i_step + 1, :));
    
    % === Loop through possible value differences === %
    for i_value_diff = 1:n_value_diff
        value_diff = all_value_diff(i_value_diff);
        % Compute the probabilistic distribution of value differences at
        % the next step
        dist_next_value_diff = ...
            exp( - (all_value_diff - value_diff) .^ 2 / ...
            (2 * (2 * gamma) ^ 2));
        dist_next_value_diff = dist_next_value_diff / ...
            sum(dist_next_value_diff);
        % Weight the expected optimal benefit at the next step by the
        % probability distrbution of value differences at the next step
        exp_optimal_benefit(i_step, i_value_diff) = sum(...
            dist_next_value_diff .* next_exp_benefit);
    end
end

end
