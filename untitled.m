all_i_step = repmat(1:4, 1, n_trials);

axmin = min([emp_w_exp_value_control(all_i_step~=4), ...
    beta_w_exp_value_control(all_i_step~=4), ...
    beta_gamma_w_exp_value_control(all_i_step~=4)]);

axmax = max([emp_w_exp_value_control(all_i_step~=4), ...
    beta_w_exp_value_control(all_i_step~=4), ...
    beta_gamma_w_exp_value_control(all_i_step~=4)]);

figure("Position", [50, 50, 1200, 500]);

subplot(1, 3, 1)
plot([0, 1], [0, 1], "k--");
hold on;
scatter(emp_w_exp_value_control(all_i_step~=4), beta_w_exp_value_control(all_i_step~=4), ...
    "filled", "MarkerFaceAlpha", 0.01);
xlabel("Threshold with empirical confidence");
ylabel("Threshold with \beta approximation");
xlim([axmin, axmax])
ylim([axmin, axmax])
axis square;

subplot(1, 3, 2)
plot([0, 1], [0, 1], "k--");
hold on;
scatter(emp_w_exp_value_control(all_i_step~=4), beta_gamma_w_exp_value_control(all_i_step~=4), ...
    "filled", "MarkerFaceAlpha", 0.01);
xlabel("Threshold with empirical confidence");
ylabel("Threshold with \beta \gamma approximation");
xlim([axmin, axmax])
ylim([axmin, axmax])
axis square;

subplot(1, 3, 3)
plot([0, 1], [0, 1], "k--");
hold on;
scatter(beta_w_exp_value_control(all_i_step~=4), beta_gamma_w_exp_value_control(all_i_step~=4), ...
    "filled", "MarkerFaceAlpha", 0.01);
xlabel("Threshold with \beta confidence");
ylabel("Threshold with \beta \gamma approximation");
xlim([axmin, axmax])
ylim([axmin, axmax])
axis square;