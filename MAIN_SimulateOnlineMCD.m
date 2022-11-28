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
fprintf("\nFinished samples generation.\n");

% === Compute empirical confidence === %

% Get samples internal states
state = getSamplesInternalStates(CueSamples);
% Get trials best option
best_option = getTrialBestOption(DataSamples);
% Compute empirical confidence
emp_confidence = computeEmpiricalConfidence(DataSamples, state, ...
    best_option);
fprintf("Computed empirical confidence.\n");

% === Compute Beta confidence === %

% Compute the beta used for approximation
[~, beta] = computePrecisionApproximationBeta(CueSamples, DataSamples);
% Approximate the confidence
beta_confidence = computeBetaConfidence(DataSamples, beta);
fprintf("Computed Beta confidence.\n");

% === Compute Beta Gamma confidence === %

% Compute the gamma used for approximation
gamma = computeDifferenceApproximationGamma(DataSamples);
% Approximate the confidence
[beta_gamma_diff_value, beta_gamma_confidence] = ...
    computeBetaGammaConfidence(DataSamples, beta, gamma);

% === Compute expected value of control === %

% Define the effort parameter
alpha = 0.1;
% Compute value of control at each sample
emp_value_control = emp_confidence - alpha * CueSamples.i_step;
beta_value_control = beta_confidence - alpha * CueSamples.i_step;
beta_gamma_value_control = beta_gamma_confidence - ...
    alpha * CueSamples.i_step;
% Compute the threshold regarding expected value of control at each sample
emp_w_exp_value_control = computeExpectedValueOfControl(CueSamples, ...
    emp_value_control);
beta_w_exp_value_control = computeExpectedValueOfControl(CueSamples, ...
    beta_value_control);
beta_gamma_w_exp_value_control = computeExpectedValueOfControl(CueSamples, ...
    beta_gamma_value_control);
fprintf("Computed expected values of control.\n");

% === Compute decision step distributions === %

% Compute decision step distribution according to the online MCD
emp_decision_step = defineDecisionStep(CueSamples, emp_value_control, ...
    emp_w_exp_value_control);
beta_decision_step = defineDecisionStep(CueSamples, beta_value_control, ...
    beta_w_exp_value_control);
beta_gamma_decision_step = defineDecisionStep(CueSamples, ...
    beta_gamma_value_control, beta_gamma_w_exp_value_control);
% Compute the best possible decision step distribution (oracle)
emp_oracle_decision_step = defineOracleDecisionStep(CueSamples, ...
    emp_value_control);
beta_oracle_decision_step = defineOracleDecisionStep(CueSamples, ...
    beta_value_control);
beta_gamma_oracle_decision_step = defineOracleDecisionStep(CueSamples, ...
    beta_gamma_value_control);
fprintf("Computed decision step distributions.\n");

% === Compute decision value of control distributions === %

% Online implementations
emp_decision_value_control = getDecisionValueOfControl(...
    emp_decision_step, emp_value_control);
beta_decision_value_control = getDecisionValueOfControl(...
    beta_decision_step, emp_value_control);
beta_gamma_decision_value_control = getDecisionValueOfControl(...
    beta_gamma_decision_step, emp_value_control);
% Oracle implementations
emp_oracle_decision_value_control = getDecisionValueOfControl(...
    emp_oracle_decision_step, emp_value_control);
beta_oracle_decision_value_control = getDecisionValueOfControl(...
    beta_oracle_decision_step, emp_value_control);
beta_gamma_oracle_decision_value_control = getDecisionValueOfControl(...
    beta_gamma_oracle_decision_step, emp_value_control);
fprintf("Computed decision value of control distributions.\n");


%% Compare decision step distributions

% Initialize figure
f_distribution_step = figure("Position", [50, 50, 1200, 600]);

% Gather information
decision_step = {emp_decision_step, beta_decision_step, ...
    beta_gamma_decision_step, emp_oracle_decision_step, ...
    beta_oracle_decision_step, beta_gamma_oracle_decision_step};
all_title = ["oMCD with empirical confidence", ...
    "oMCD with \beta confidence", ...
    "oMCD with \beta \gamma confidence", ...
    "Oracle with empirical confidence", ...
    "Oracle with \beta confidence", ...
    "Oracle with \beta \gamma confidence"];

% === Loop over subplots === %
for i_plot = 1:6
    % Define subplot
    subplot(2, 3, i_plot);
    % Plot histogram
    h = histogram(decision_step{i_plot}, "Normalization", "probability");
    % Set aesthetics
    xlabel("Decision step");
    xticks(1:4);
    ylim([0, 0.7]);
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
    select_best_step = (emp_oracle_decision_step == i_best_step);
    
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
    "Decision step predicted by oMCD with \beta confidence", ...
    "Decision step predicted by oMCD with \beta \gamma confidence"];
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
    xlabel("Best decision step");
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
    s = scatter(emp_oracle_decision_value_control, ...
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
        emp_oracle_decision_step);
    % Set datatip rows
    s.DataTipTemplate.DataTipRows(1).Label = "Oracle value of control";
    s.DataTipTemplate.DataTipRows(2).Label = "Online value of control";
    s.DataTipTemplate.DataTipRows(3) = row_decision_step;
    s.DataTipTemplate.DataTipRows(4) = row_best_decision_step;

    % === Distributions of the difference in performance === %

    % Define subplot
    subplot(2, 3, i_plot + 3);
    % Compute the difference in performance compared to the oracle
    diff_decision_value_control = emp_oracle_decision_value_control - ...
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
