% Computes the optimal decision threshold determining for which value
% difference an agent using the online MCD should stop.

function optimal_threshold = computeOptimalThreshold(all_value_diff, ...
    exp_optimal_benefit, alpha, beta)
% Parameters
% ----------
% all_value_diff: [1 x n_value_diff] double
%   All considered possible value differences.
% exp_optimal_benefit: [T x n_value_diff] double
%   Optimal benefit expected at time t regarding t + 1, for all possible
%   value differences.
% alpha: double
%   Effort parameter.
% beta: double
%   Linear coefficient linking variance on the difference between
%   estimated values with trial step.
%
% Outputs
% -------
% optimal_threshold: [1 x T] double
%   Absolute value difference threshold under which sampling must continue,
%   and over which sampling must stop.


% Initialize output
T = size(exp_optimal_benefit, 1);
optimal_threshold = NaN(1, T);

% Only consider positive value differences (i.e. absolute differences)
select_value_diff = all_value_diff > 0;
all_value_diff = all_value_diff(select_value_diff);
exp_optimal_benefit = exp_optimal_benefit(:, select_value_diff);

% Define horizon threshold
optimal_threshold(T) = - Inf;

% === Loop through steps === %
for i_step = 1:(T - 1)
    % Compute the benefit of stopping now
    current_benefit_stop = computeBetaConfidenceDiff(all_value_diff, ...
        beta, i_step) - alpha * i_step;
    % Find when the benefit of stopping now equals the expected optimal
    % benefit at the next step
    [~, i_min_diff] = min(abs(...
        current_benefit_stop - exp_optimal_benefit(i_step, :)));
    % Store the corresponding value difference
    optimal_threshold(i_step) = all_value_diff(i_min_diff);
end

end
