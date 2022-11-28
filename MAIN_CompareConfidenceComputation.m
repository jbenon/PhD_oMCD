setMatlabPath

clear variables

close all

% === Prepare orthogonal samples === %

% Generate orthogonal samples
CueSamples = generateCueSamples("padoa-schioppa");
% Expand generated samples
DataSamples = expandCueSamples(CueSamples);
fprintf("\nFinished samples generation.\n")

% === Compute empirical confidence === %

% Get samples internal states
state = getSamplesInternalStates(CueSamples);
% Get trials best option
best_option = getTrialBestOption(DataSamples);
% Compute empirical confidence
emp_confidence = computeEmpiricalConfidence(DataSamples, state, ...
    best_option);
fprintf("Computed empirical confidence.\n");
% Find non-degenerative samples
sample_problem = findNonDegenerativeStepsInEmpiricalConfidence(...
    DataSamples, emp_confidence);
% Find non-degenerative trials
trial_problem = any(reshape(sample_problem, 4, []), 1);
fprintf("%d/%d problematic trials\n", ...
    sum(trial_problem), DataSamples.i_trial(end));

% === Compute Beta confidence === %

% Compute the beta used for approximation
[~, beta] = computePrecisionApproximationBeta(CueSamples, DataSamples);
fprintf("Computed beta for approximation.\n");
% Approximate the confidence
beta_confidence = computeBetaConfidence(DataSamples, beta);

% === Compute Beta Gamma confidence === %

% Compute the gamma used for approximation
gamma = computeDifferenceApproximationGamma(DataSamples);
% Approximate the confidence
[beta_gamma_diff_value, beta_gamma_confidence] = ...
    computeBetaGammaConfidence(DataSamples, beta, gamma);


%% Plot confidence histograms

f_conf_hist = figure("Position", [50, 50, 800, 600]);

% === Loop over steps === %
for i_step = 1:4
    % Define the subplot
    subplot(2, 2, i_step);

    % === Histogram === %

    % Empirical confidence histogram
    histogram(emp_confidence(i_step:4:end), 50, ...
        "Normalization", "probability", ...
        "FaceAlpha", 0.5);
    % Beta confidence histogram
    hold on;
    histogram(beta_confidence(i_step:4:end), 50, ...
        "Normalization", "probability", ...
        "FaceAlpha", 0.5);
    % Beta gamma confidence histogram
    hold on;
    histogram(beta_gamma_confidence(i_step:4:end), 50, ...
        "Normalization", "probability", ...
        "FaceAlpha", 0.5);

    % === Aesthetics === %

    % Set axis aesthetics
    xlabel("Confidence");
    ylabel("Number of samples");
    xlim([0.4, 1.05])
    ylim([0, 1]);
    % Write title
    title(sprintf("Confidence at step %d", i_step));
    % Show legend
    legend(["Empirical", "Beta approximation", "Beta Gamma approximation"], ...
        "Location", "north");
end


%% Plot absolute value difference histograms

f_val_diff_hist = figure("Position", [50, 50, 800, 600]);

% === Loop over steps === %
for i_step = 1:4
    % Define the subplot
    subplot(2, 2, i_step);

    % === Histogram === %

    % Empirical absolute value difference
    h1 = histogram(abs(DataSamples.value_left(i_step:4:end) - ...
        DataSamples.value_right(i_step:4:end)), 50, ...
        "Normalization", "probability", ...
        "FaceAlpha", 0.5);
    % Gamma predicted absolute value difference
    hold on;
    histogram(NaN);
    h2 = histogram(beta_gamma_diff_value(i_step:4:end), 50, ...
        "Normalization", "probability", ...
        "FaceAlpha", 0.5);

    % === Aesthetics === %

    % Set axis aesthetics
    xlabel("Absolute value difference");
    ylabel("Number of samples");
    xlim([-0.05, 1])
    ylim([0, 0.25]);
    % Write title
    title(sprintf("Absolute value difference at step %d", i_step));
    % Show legend
    legend([h1, h2], ["Empirical", "Gamma approximation"], ...
        "Location", "northeast");
end


%% Plot confidence as a function of value difference in non-degenerative
% and generative trials

f_degenerative = figure("Position", [50, 50, 800, 600]);

% Enable datatips
datacursormode(f_degenerative, "on");

% Select info of samples which do not cause a non-degenerative problem
degenerative_step = CueSamples.i_step(~ sample_problem);
degenerative_value_left = DataSamples.value_left(~ sample_problem);
degenerative_value_right = DataSamples.value_right(~ sample_problem);
degenerative_confidence = emp_confidence(~ sample_problem);
degenerative_state = state(:, ~ sample_problem);

% Select info of samples which cause a non-degenerative problem
nondegenerative_step = CueSamples.i_step(sample_problem);
nondegenerative_value_left = DataSamples.value_left(sample_problem);
nondegenerative_value_right = DataSamples.value_right(sample_problem);
nondegenerative_confidence = emp_confidence(sample_problem);
nondegenerative_state = state(:, sample_problem);

% === Loop over steps === %
for i_step = 1:4
    % Define the subplot
    subplot(2, 2, i_step);

    % === Scatter plot === %

    % Select time steps for degenerative trials
    select_dege_step = (degenerative_step == i_step);
    % Empirical confidence of degenerative samples
    s_dege = scatter(abs(...
        degenerative_value_left(select_dege_step) - ...
        degenerative_value_right(select_dege_step)), ...
        degenerative_confidence(select_dege_step), "filled", ...
        "MarkerFaceAlpha", 0.01);
    % Select time steps for non-degenerative trials
    select_nondege_step = (nondegenerative_step == i_step);
    % Scatter plot of degenerative samples
    hold on;
    s_nondege = scatter(abs(...
        nondegenerative_value_left(select_nondege_step) - ...
        nondegenerative_value_right(select_nondege_step)), ...
        nondegenerative_confidence(select_nondege_step), "filled", ...
        "MarkerFaceAlpha", 0.01);

    % === Aesthetics === %

    % Set axis aesthetics
    xlabel("Absolute difference in option values");
    ylabel("Empirical confidence");
    xlim([0, 1])
    ylim([0.4, 1]);
    % Write title
    title(sprintf("Step %d", i_step));
    % Show legend
    lure(1) = scatter(NaN, NaN, "filled", ...
        "MarkerFaceColor", [0; 0.447; 0.741], ...
        "MarkerFaceAlpha", 0.7);
    lure(2) = scatter(NaN, NaN, "filled", ...
        "MarkerFaceColor", [0.85; 0.325; 0.098], ...
        "MarkerFaceAlpha", 0.7);
    legend(lure, ["Degenerative", "Non-degenerative"], ...
        "Location", "southeast")

    % === Datatips === %
    
    % Create datatip rows for degenerative samples
    row_dege_prob_left = dataTipTextRow("Probability left", ...
        state(1, select_dege_step));
    row_dege_mag_left = dataTipTextRow("Magnitude left", ...
        state(2, select_dege_step));
    row_dege_prob_right = dataTipTextRow("Probability right", ...
        state(3, select_dege_step));
    row_dege_mag_right = dataTipTextRow("Magnitude right", ...
        state(4, select_dege_step));
    % Create datatip rows for non-degenerative samples
    row_nondege_prob_left = dataTipTextRow("Probability left", ...
        state(1, select_nondege_step));
    row_nondege_mag_left = dataTipTextRow("Magnitude left", ...
        state(2, select_nondege_step));
    row_nondege_prob_right = dataTipTextRow("Probability right", ...
        state(3, select_nondege_step));
    row_nondege_mag_right = dataTipTextRow("Magnitude right", ...
        state(4, select_nondege_step));
    % Set datatips for degenerative samples
    s_dege.DataTipTemplate.DataTipRows(1).Label = "Absolute value difference";
    s_dege.DataTipTemplate.DataTipRows(2).Label = "Empirical confidence";
    s_dege.DataTipTemplate.DataTipRows(3) = row_dege_prob_left;
    s_dege.DataTipTemplate.DataTipRows(4) = row_dege_mag_left;
    s_dege.DataTipTemplate.DataTipRows(5) = row_dege_prob_right;
    s_dege.DataTipTemplate.DataTipRows(6) = row_dege_mag_right;
    % Set datatips for non-degenerative samples
    s_nondege.DataTipTemplate.DataTipRows(1).Label = "Absolute value difference";
    s_nondege.DataTipTemplate.DataTipRows(2).Label = "Empirical confidence";
    s_nondege.DataTipTemplate.DataTipRows(3) = row_nondege_prob_left;
    s_nondege.DataTipTemplate.DataTipRows(4) = row_nondege_mag_left;
    s_nondege.DataTipTemplate.DataTipRows(5) = row_nondege_prob_right;
    s_nondege.DataTipTemplate.DataTipRows(6) = row_nondege_mag_right;
end


%% Plot confidence as a function of value difference

f_valuediff_conf = figure("Position", [50, 50, 800, 600]);

% Enable datatips
datacursormode(f_valuediff_conf, "on");

% === Loop over steps === %
for i_step = 1:4
    % Define the subplot
    subplot(2, 2, i_step);

    % === Scatter plot === %

    % Empirical confidence
    s_emp = scatter(abs(DataSamples.value_left(i_step:4:end) - ...
        DataSamples.value_right(i_step:4:end)), ...
        emp_confidence(i_step:4:end), ...
        40, ...
        "filled", ...
        "MarkerFaceAlpha", 1);
    % Beta confidence
    hold on;
    s_beta = scatter(abs(DataSamples.value_left(i_step:4:end) - ...
        DataSamples.value_right(i_step:4:end)), ...
        beta_confidence(i_step:4:end), ...
        30, ...
        "filled", ...
        "MarkerFaceAlpha", 1);
    % Beta gamma confidence
    hold on;
    s_beta_gamma = scatter(abs(DataSamples.value_left(i_step:4:end) - ...
        DataSamples.value_right(i_step:4:end)), ...
        beta_gamma_confidence(i_step:4:end), ...
        12, ...
        "filled", ...
        "MarkerFaceAlpha", 0.1);

    % === Aesthetics === %

    % Set axis aesthetics
    xlabel("Absolute difference in option values");
    ylabel("Confidence");
    xlim([0, 1]);
    ylim([0.4, 1]);
    % Write title
    title(sprintf("Step %d", i_step));
    % Show legend
    legend(["Empirical", "Beta approximation", "Beta Gamma approximation"], ...
        "Location", "southeast")

    % === Datatips === %

    % Create datatip rows
    row_beta_confidence = dataTipTextRow("Beta confidence", ...
        beta_confidence(i_step:4:end));
    row_beta_gamma_confidence = dataTipTextRow("Beta gamma confidence", ...
        beta_gamma_confidence(i_step:4:end));
    row_prob_left = dataTipTextRow("Probability left", ...
        state(1, i_step:4:end));
    row_mag_left = dataTipTextRow("Magnitude left", ...
        state(2, i_step:4:end));
    row_prob_right = dataTipTextRow("Probability right", ...
        state(3, i_step:4:end));
    row_mag_right = dataTipTextRow("Magnitude right", ...
        state(4, i_step:4:end));
    % Set datatips for empirical points
    s_emp.DataTipTemplate.DataTipRows(1).Label = "Absolute value difference";
    s_emp.DataTipTemplate.DataTipRows(2).Label = "Empirical confidence";
    s_emp.DataTipTemplate.DataTipRows(3) = row_beta_confidence;
    s_emp.DataTipTemplate.DataTipRows(4) = row_beta_gamma_confidence;
    s_emp.DataTipTemplate.DataTipRows(5) = row_prob_left;
    s_emp.DataTipTemplate.DataTipRows(6) = row_mag_left;
    s_emp.DataTipTemplate.DataTipRows(7) = row_prob_right;
    s_emp.DataTipTemplate.DataTipRows(8) = row_mag_right;
end


%% Evaluate approximation performance

% === Fit linear model === %
mdl = fitlm(beta_confidence', emp_confidence', ...
    "linear", ...
    "VarNames", ["Beta confidence", "Empirical confidence"]);

% === Plot linear fitting === %

% Scatter plot
f_beta = figure;
plot(mdl);
% Display linear equation
text(0.7, 0.9, ...
    sprintf("EmpConf = %0.3f x BetaConf + %0.3f", ...
    mdl.Coefficients.Estimate(2), mdl.Coefficients.Estimate(1)), ...
    "Color", "k", "HorizontalAlignment", "center");
% Display R2
text(0.7, 0.87, ...
    sprintf("R^2 adjusted = %0.3f", mdl.Rsquared.Adjusted), ....
    "Color", "k", "HorizontalAlignment", "center");
