all_value_diff = -2:0.001:2;

% Step 4
opt_benefit_step4 = 1 - alpha * 4;
threshold_4 = 0.5 - alpha * 4;

% Step 3
benefit_stop3 = VBA_sigmoid((pi * abs(all_value_diff)) ./ ...
    sqrt(3 * 2 * beta * (4 - 3))) - alpha * 3;
% exp_abs_value_diff_step4 = 2 * sqrt(gamma / pi) * ...
%     exp(- abs(all_value_diff) .^ 2 ./ (4 * gamma)) + all_value_diff .* ...
%     (2 * VBA_sigmoid((pi * all_value_diff) / sqrt(6 * gamma)) - 1);
% var_abs_value_diff_step4 = 2 * gamma + abs(all_value_diff) .^ 2 - ...
%     exp_abs_value_diff_step4;
% lambda = 1 / sqrt(3 * 2 * beta * (4 - 4));
exp_benefit_stop_step4 = 1 - alpha * 4;
opt_benefit_step3 = max(benefit_stop3, exp_benefit_stop_step4);

% Step 2
benefit_stop2 = VBA_sigmoid((pi * abs(all_value_diff)) ./ ...
    sqrt(3 * 2 * beta * (4 - 2))) - alpha * 2;
for i_value_diff = 1:length(all_value_diff)
    value_diff = all_value_diff(i_value_diff);
    dist = exp(- (all_value_diff - value_diff).^2 /(2*(2*gamma)^2));
    dist = dist / sum(dist);
    exp_opt_benefit_step3(i_value_diff) = ...
        sum(dist .* max(benefit_stop3, opt_benefit_step4));
end

% Step 1
for i_value_diff = 1:length(all_value_diff)
    value_diff = all_value_diff(i_value_diff);
    dist = exp(- (all_value_diff - value_diff).^2 /(2*(2*gamma)^2));
    dist = dist / sum(dist);
    exp_opt_benefit_step2(i_value_diff) = ...
        sum(dist .* max(benefit_stop2, exp_opt_benefit_step3));
end
