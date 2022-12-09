setMatlabPath

clear variables

close all

% === Prepare exploration of orthogonal samples === %

% Generate orthogonal samples
CueSamples = generateCueSamples("padoa-schioppa");
% Expand samples information
DataSamples = expandCueSamples(CueSamples);
% Get sampling information
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);

% === Compute empirical value of control === %

% Get samples internal states
state = getSamplesInternalStates(CueSamples);
% Get trials best option
best_option = getTrialBestOption(DataSamples);
% Compute empirical confidence
emp_confidence = computeEmpiricalConfidence(DataSamples, state, ...
    best_option);
% Define the effort parameter
alpha = 0.1;
% Compute empirical value of control
emp_value_control = emp_confidence - alpha * DataSamples.i_step;

% === Prepare approximation === %

% Compute the beta used for approximation
[~, beta] = computeVarianceApproximationBeta(CueSamples, DataSamples);
% Compute the gamma used for approximation
[~, gamma] = computeDifferenceApproximationGamma(DataSamples);
% Approximate the confidence
beta_confidence = computeBetaConfidence(...
    DataSamples.value_left, DataSamples.value_right, ...
    beta, DataSamples.i_step);
% Approximate the value of control
beta_value_control = beta_confidence - alpha * DataSamples.i_step;

% === Compute decision thresholds === %

% Empirical threshold
emp_w_exp_value_control = predictExpectedValueOfControl(...
    emp_confidence, alpha);
% Approximation threshold with beta only
beta_w_exp_value_control = predictExpectedValueOfControl(...
    beta_confidence, alpha);
% Full oMCD approximation
all_value_diff = -2:0.001:2;
MAIN_computeAllOptimalBenefit_oMCD;
beta_gamma_w_exp_value_control = NaN(1, n_samples);
for i_trial = 1:n_trials
    for i_step = 1:4
        i_sample = (i_trial - 1) * 4 + i_step;
        % Find corresponding value difference
        value_diff = DataSamples.value_left(i_sample) - DataSamples.value_right(i_sample);
        [~, i_value_diff] = min(abs(all_value_diff - value_diff));
        % Get corresponding threshold
        switch i_step
            case 1
                beta_gamma_w_exp_value_control(i_sample) = ...
                    exp_opt_benefit_step2(i_value_diff);
            case 2
                beta_gamma_w_exp_value_control(i_sample) = ...
                    exp_opt_benefit_step3(i_value_diff);
            case 3
                beta_gamma_w_exp_value_control(i_sample) = ...
                    opt_benefit_step3(i_value_diff);
            case 4
                beta_gamma_w_exp_value_control(i_sample) = ...
                    opt_benefit_step4;
        end
    end
end
%%
% beta_gamma_w_exp_value_control = predictExpectedValueOfControlGamma(...
%     DataSamples.value_left, DataSamples.value_right, alpha, beta, gamma);

% === Compute decision steps === %

% Compute decision step distribution according to the online MCD
emp_decision_step = defineDecisionStep(emp_value_control, ...
    emp_w_exp_value_control);
beta_decision_step = defineDecisionStep(beta_value_control, ...
    beta_w_exp_value_control);
beta_gamma_decision_step = defineDecisionStep(beta_value_control, ...
    beta_gamma_w_exp_value_control);
% Compute the best possible decision step distribution (oracle)
oracle_decision_step = defineOracleDecisionStep(emp_value_control);

% === Compute value of control at the decision time === %

% Online implementations
emp_decision_value_control = getDecisionValueOfControl(...
    emp_decision_step, emp_value_control);
beta_decision_value_control = getDecisionValueOfControl(...
    beta_decision_step, emp_value_control);
beta_gamma_decision_value_control = getDecisionValueOfControl(...
    beta_gamma_decision_step, emp_value_control);
% Oracle implementations
oracle_decision_value_control = getDecisionValueOfControl(...
    oracle_decision_step, emp_value_control);


%% Compare decision step distributions

% Initialize figure
f_distribution_step = figure("Position", [50, 50, 1400, 400]);

% Gather information
decision_step = {emp_decision_step, beta_decision_step, ...
    beta_gamma_decision_step, oracle_decision_step};
all_title = ["oMCD with empirical confidence", ...
    "oMCD with \beta approximation", ...
    "oMCD with \beta \gamma approximation", ...
    "Oracle"];

% === Loop over subplots === %
for i_plot = 1:length(decision_step)
    % Define subplot
    subplot(1, length(decision_step), i_plot);
    % Plot histogram
    h = histogram(decision_step{i_plot}, "Normalization", "probability");
    % Set aesthetics
    xlabel("Decision step");
    xticks(1:4);
    ylim([0, 0.85]);
    title(all_title(i_plot));
    % Compute distribution entropy
    entropy = - sum (h.Values .* log(h.Values));
    % Write distribution entropy
    text(2.5, 0.5, sprintf("Entropy = %0.4f", entropy), ...
        "HorizontalAlignment", "center");
end


%% Compare decision step distributions across strategies

% === Count the proportion of predicted decision step for each best
% decision step === %

% Initialize arrays
emp_prop_predicted = NaN(4, 4);
beta_prop_predicted = NaN(4, 4);
beta_gamma_prop_predicted = NaN(4, 4);

% === Loop over best decision step === %
for i_best_step = 1:4
    % Select the trials where the best decision was indeed this step
    select_best_step = (oracle_decision_step == i_best_step);
    
    % === Loop over predicyed decision step === %
    for i_pred_step = 1:4
        % Select the trials where this step was predicted by the online MCD
        emp_select_pred_step = (emp_decision_step == i_pred_step);
        beta_select_pred_step = (beta_decision_step == i_pred_step);
        beta_gamma_select_pred_step = ...
            (beta_gamma_decision_step == i_pred_step);
        % Store the information
        emp_prop_predicted(i_pred_step, i_best_step) = ...
            sum(select_best_step & emp_select_pred_step);
        beta_prop_predicted(i_pred_step, i_best_step) = ...
            sum(select_best_step & beta_select_pred_step);
        beta_gamma_prop_predicted(i_pred_step, i_best_step) = ...
            sum(select_best_step & beta_gamma_select_pred_step);
    end

    % Normalize by the number of truaks where the best decision was indeed
    % this step
    emp_prop_predicted(:, i_best_step) = ...
        emp_prop_predicted(:, i_best_step) / sum(select_best_step);
    beta_prop_predicted(:, i_best_step) = ...
        beta_prop_predicted(:, i_best_step) / sum(select_best_step);
    beta_gamma_prop_predicted(:, i_best_step) = ...
        beta_gamma_prop_predicted(:, i_best_step) / sum(select_best_step);
end

% === Plot heatmaps === %

% Initialize figure
f_compare_decision_step = figure("Position", [50, 50, 1300, 500]);
% Gather information
prop_predicted = {emp_prop_predicted, beta_prop_predicted, ...
    beta_gamma_prop_predicted};
all_yaxis = ...
    ["Decision step predicted by oMCD with empirical confidence", ...
    "Decision step predicted by oMCD with \beta approximation", ...
    "Decision step predicted by oMCD with \beta \gamma approximation"];
% Compute distance to identity
dist_id = NaN(1,3);
weight_kernel = ...
    [1, 2, 3, 4; ...
     2, 1, 2, 3; ...
     3, 2, 1, 2; ...
     4, 3, 2, 1];
for i_plot = 1:3
    dist_id(i_plot) = norm(prop_predicted{i_plot} .* weight_kernel - ...
        eye(4));
end
% === Loop over subplots === %
for i_plot = 1:3
    % Define subplot
    subplot(1, 3, i_plot);
    % Plot heatmap
    imagesc(prop_predicted{i_plot});
    % Set axis aesthetics
    xlabel("Oracle decision step");
    ylabel(all_yaxis(i_plot));
    xticks(1:4);
    yticks(1:4);
    axis square;
    % Set colorbar
    cb = colorbar;
    cb.Label.String = "Proportion of trials";
    clim([0, 1]);
    % Display cell values
    [x_text, y_text] = meshgrid(1:4, 1:4);
    prop_text = round(prop_predicted{i_plot}, 3);
    prop_text = cellfun(@num2str, num2cell(prop_text), ...
        "UniformOutput", false);
    text(x_text(:), y_text(:), prop_text, "HorizontalAlignment", "center");
    % Title: Frobenius distance from identity matrix
    title(sprintf("Distance to identity: %0.3f", dist_id(i_plot)));
end


%% Compare the selected value of control across strategies

% Initialize figure
f_compare_decision_vc = figure("Position", [50, 50, 1200, 800]);

% Enable datatips
datacursormode(f_compare_decision_vc, "on");

% Gather information
decision_value_control = {emp_decision_value_control, ...
    beta_decision_value_control, beta_gamma_decision_value_control};
decision_step = {emp_decision_step, beta_decision_step, ...
    beta_gamma_decision_step};
all_data_name = ["empirical oMCD", "\beta oMCD", "\beta \gamma oMCD"];

% === Loop over subplots === %
for i_plot = 1:3

    % === Scatter plots comparing achieved value of control to oracle === %

    % Define subplot
    subplot(2, 3, i_plot);
    % Draw identity line
    plot([0, 1], [0, 1], "k--");
    hold on;
    % Scatter plot
    s = scatter(oracle_decision_value_control, ...
        decision_value_control{i_plot}, ...
        "filled");
    % Set axis aesthetics
    xlabel("Best possible value of control at decision step");
    ylabel(sprintf("Value of control at decision step with %s", ...
        all_data_name(i_plot)));
    xlim([0.55, 0.85]);
    ylim([0.2, 0.85]);
    axis square;
    % Create datatip rows
    row_decision_step = dataTipTextRow("Online decision step", ...
        decision_step{i_plot});
    row_best_decision_step = dataTipTextRow("Oracle decision step", ...
        oracle_decision_step);
    % Set datatip rows
    s.DataTipTemplate.DataTipRows(1).Label = "Oracle value of control";
    s.DataTipTemplate.DataTipRows(2).Label = "Online value of control";
    s.DataTipTemplate.DataTipRows(3) = row_decision_step;
    s.DataTipTemplate.DataTipRows(4) = row_best_decision_step;

    % === Distributions of the difference in performance === %

    % Define subplot
    subplot(2, 3, i_plot + 3);
    % Compute the difference in performance compared to the oracle
    diff_decision_value_control = oracle_decision_value_control - ...
        decision_value_control{i_plot};
    % Cumulative plot
    cdfplot(diff_decision_value_control);
    % Mean line
    xline(mean(diff_decision_value_control), "r-", "LineWidth", 2);
    % Write mean annotation
    text(mean(diff_decision_value_control) + 0.01, 0.3, "Mean", ...
        "Rotation", 90, "HorizontalAlignment", "center", ...
        "VerticalAlignment", "middle", "Color", "r");
    % Set axis aesthetics
    xlabel(sprintf(...
        "Difference in achieved values of control\nbetween %s and oracle", ...
        all_data_name(i_plot)));
    ylabel("P(difference \leq x)")
    xlim([-0.01, 0.51]);
    ylim([0, 1.05]);
    axis square
    % Remove subplot title
    title("");
end


%% Compare the empirical value of control to the Beta approximation

figure("Position", [50, 50, 700, 700]);

% === Loop over steps === %
for i_step = 1:4
    % Define subplot
    subplot(2, 2, i_step);

    % Scatter plot of values of control
    scatter(emp_value_control(DataSamples.i_step == i_step), ...
        beta_value_control(DataSamples.i_step == i_step), ...
        "filled", "MarkerFaceAlpha", 0.01);
    % Identity line
    hold on;
    plot([0, 1], [0, 1], "k--");
    % Subplot aesthetics
    title(sprintf("Step n°%d", i_step));
    % Axis aesthetics
    xlim([0.15, 0.85]);
    ylim([0.15, 0.85]);
    axis square
    xlabel("Empirical value of control")
    ylabel("Approximated value of control using \beta")
end


%% Look at the evolution of the decision threshold over steps

figure("Position", [50, 50, 1200, 400]);

% Gather information
threshold = {emp_w_exp_value_control, beta_w_exp_value_control, ...
    beta_gamma_w_exp_value_control};
all_title = ["No approximation", "\beta approximation", ...
    "\beta \gamma approximation"];

% === Loop through methods === %
for i_plot = 1:length(threshold)
    % Define subplot
    subplot(1, 3, i_plot);
    % Plot
    plot(reshape(threshold{i_plot}, 4, []), ...
        "o-", "Color", [0, 0, 0, 0.008]);
    % Axis aesthetics
    xticks(1:4);
    ylim([0.55, 0.75]);
    xlabel("Step");
    ylabel("Decision threshold");
    % Plot asthetics
    title(all_title(i_plot));
end


%% Compare the decision thresholds of the three methods

figure("Position", [50, 50, 1200, 400]);

% Gather information
all_x_thresholds = {emp_w_exp_value_control, emp_w_exp_value_control, ...
    beta_w_exp_value_control};
all_y_thresholds = {beta_w_exp_value_control, ...
    beta_gamma_w_exp_value_control, beta_gamma_w_exp_value_control};
all_x_labels = ["Decision threshold without approximation", ...
    "Decision threshold without approximation", ...
    "Decision threshold with \beta approximation"];
all_y_labels = ["Decision threshold with \beta approximation", ...
    "Decision threshold with \beta \gamma approximation", ...
    "Decision threshold with \beta \gamma approximation"];

% === Loop through methods === %
for i_plot = 1:length(all_x_thresholds)
    % Define the subplot
    subplot(1, length(all_x_thresholds), i_plot);
    % Plot
    scatter(all_x_thresholds{i_plot}, all_y_thresholds{i_plot}, ...
        "filled", "MarkerFaceAlpha", 0.01);
    % Identity line
    hold on;
    plot([0, 1], [0, 1], "k--");
    % Axis asthetics
    xlim([0.55, 0.75]);
    ylim([0.55, 0.75]);
    xlabel(all_x_labels(i_plot));
    ylabel(all_y_labels(i_plot));
    axis square;
end


%% Look at the evolution of confidence over steps

f_confidence_steps = figure("Position", [50, 50, 1000, 400]);

% Enable datatips
datacursormode(f_confidence_steps, "on");

% Gather information
confidence = {emp_confidence, beta_confidence};
all_title = ["No approximation", "\beta approximation"];

% === Loop through methods === %
for i_plot = 1:length(confidence)
    % Define subplot
    subplot(1, length(confidence), i_plot);
    % Plot
    p = plot(reshape(confidence{i_plot}, 4, []), ...
        "o-", "Color", [0, 0, 0, 0.008]);
    % Axis aesthetics
    xticks(1:4);
    ylim([0.45, 1]);
    xlabel("Step");
    ylabel("Confidence");
    % Plot asthetics
    title(all_title(i_plot));
    for i_trial = 1:n_trials
        % Create datatip rows
        row_i_trial = dataTipTextRow("Trial n°", repelem(i_trial, 4));
        % Set datatip rows
        p(i_trial).DataTipTemplate.DataTipRows(1).Label = "Step";
        p(i_trial).DataTipTemplate.DataTipRows(2).Label = "Confidence";
        p(i_trial).DataTipTemplate.DataTipRows(3) = row_i_trial;
    end
end


%% Look at the decision threshold for varying value differences, using beta and beta gamma approximation

all_value_diff = -2:0.001:2;

figure("Position", [50, 50, 900, 900]);

% Step 1
subplot(2, 2, 1)
plot(all_value_diff, VBA_sigmoid((pi * abs(all_value_diff)) ./ ...
    sqrt(3 * 2 * beta * (4 - 1))) - alpha * 1);
hold on;
plot(all_value_diff, exp_opt_benefit_step2);
legend(["Value of control", "Expected optimal discounted benefit at t = 2"], ...
    "Location", "south");
xlim([-1, 1]);
ylim([0.1, 0.9]);
xlabel("V_{left} - V_{right}");
title("Step n°1");

% Step 2
subplot(2, 2, 2)
plot(all_value_diff, VBA_sigmoid((pi * abs(all_value_diff)) ./ ...
    sqrt(3 * 2 * beta * (4 - 2))) - alpha * 2);
hold on;
plot(all_value_diff, exp_opt_benefit_step3);
legend(["Value of control", "Expected optimal discounted benefit at t = 3"], ...
    "Location", "south");
xlim([-1, 1]);
ylim([0.1, 0.9]);
xlabel("V_{left} - V_{right}");
title("Step n°2");

% Step 3
subplot(2, 2, 3)
plot(all_value_diff, VBA_sigmoid((pi * abs(all_value_diff)) ./ ...
    sqrt(3 * 2 * beta * (4 - 3))) - alpha * 3);
hold on;
plot(all_value_diff, opt_benefit_step3);
legend(["Value of control", "Optimal discounted benefit at t = 3"], ...
    "Location", "south");
xlim([-1, 1]);
ylim([0.1, 0.9]);
xlabel("V_{left} - V_{right}");
title("Step n°3");

% Step 4
subplot(2, 2, 4)
plot(all_value_diff, VBA_sigmoid((pi * abs(all_value_diff)) ./ ...
    sqrt(3 * 2 * beta * (4 - 4))) - alpha * 4);
legend(["Value of control"], ...
    "Location", "south");
xlim([-1, 1]);
ylim([0.1, 0.9]);
xlabel("V_{left} - V_{right}");
title("Step n°4");