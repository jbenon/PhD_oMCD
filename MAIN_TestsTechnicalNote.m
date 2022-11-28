setMatlabPath;

%% 0 - Proactive MCD model

% === Set model parameters === %

% Set MCD parameters
beta = 2;
gamma = 1;
alpha = 0.0005;
nu = 1;
R = 1;
% Set value priors
prior_mu = [1, 1.5]';
prior_delta_mu = prior_mu(1) - prior_mu(2);
prior_sigma = [1, 1]';

% === Set simulation parameters === %

% Set the length of each simulation
tot_z = 100;
% Set the number of simulations
n_simu = 1000;

% === Initialize storage === %

% Empirical absolute difference in mus given resources z
delta_mu = NaN(n_simu, tot_z);
% Lambda factor
lambda = NaN(n_simu, tot_z);
% Confidence
confidence = NaN(n_simu, tot_z);
% Value of control
value_control = nan(n_simu, tot_z);

% === Loop over simulations === %
for i_simu = 1:n_simu
    % Initialize value evaluation storage
    mu = NaN(tot_z, 2);
    sigma = NaN(tot_z, 2);
    
    % === Loop over invested resources === %
    for z = 1:tot_z
        % Update the value estimates
        mu(z, :) = prior_mu + sqrt(gamma * z) * randn(2, 1);
        sigma(z, :) = 1 ./ ((1 ./ prior_sigma) + beta * z);
    end
    
    % Store simulation information
    delta_mu(i_simu, :) = abs(mu(:, 1) - mu(:, 2));
    lambda(i_simu, :) = pi ./ sqrt(3 * (sigma(:, 1) + sigma(:, 2)));
    confidence(i_simu, :) = VBA_sigmoid(lambda(i_simu, :) .* ...
        delta_mu(i_simu, :));
    value_control(i_simu, :) = R * confidence(i_simu, :) - ...
        alpha * (1:tot_z) .^ nu;
end

% === Compute empirical statistics === %

% Expected difference
emp_exp_delta_mu = mean(delta_mu, 1);
% Variance of the difference
emp_var_delta_mu = var(delta_mu, 0, 1);
% Expected confidence (non-empirical definition of confidence)
disp("/!\ Non empirical definition of confidence");
emp_exp_confidence = mean(confidence, 1);
% Expected value of control
emp_exp_value_control = mean(value_control, 1);

% === Compute predicted statistics === %

z = 1:tot_z;
% Expected difference
pred_exp_delta_mu = 2 * sqrt((gamma * z) / pi) .* ...
    exp(- (abs(prior_delta_mu) ^ 2) ./ (4 * gamma * z)) + ...
    prior_delta_mu * ...
    (2 * VBA_sigmoid((pi * prior_delta_mu) ./ sqrt(6 * gamma * z)) - 1);
% Variance of the difference
pred_var_delta_mu = 2 * gamma * z + abs(prior_delta_mu)^2 - ...
    pred_exp_delta_mu.^2;
% Expected confidence (semi-empirical: uses the empirical lambda
pred_sigma = [1 ./ ((1 / prior_sigma(1)) + beta * z);  ...
    1 ./ ((1 / prior_sigma(2)) + beta * z)];
pred_lambda = pi ./ sqrt(3 * (pred_sigma(1, :) + pred_sigma(1, :)));
pred_exp_confidence = VBA_sigmoid((pred_lambda .* pred_exp_delta_mu) ./ ...
    sqrt(1 + 0.5 * ((pred_lambda .^ 2) .* pred_var_delta_mu) .^(3/4)));
% Expected value of control
pred_exp_value_control = R * pred_exp_confidence - ...
        alpha * (1:tot_z) .^ nu;

% === Plot === %

% Expected difference
figure;
ax1 = subplot(1, 3, 1);
plot(emp_exp_delta_mu);
title("Empirical expected diff");
ax2 = subplot(1, 3, 2);
plot(pred_exp_delta_mu);
title("Predicted expected diff");
subplot(1, 3, 3);
plot(pred_exp_delta_mu, emp_exp_delta_mu, "k.");
xlabel("Predicted");
ylabel("Empirical");
title("Empirical vs. Predicted");
linkaxes([ax1, ax2]);

% Variance of difference
figure;
ax1 = subplot(1, 3, 1);
plot(emp_var_delta_mu);
title("Empirical variance");
ax2 = subplot(1, 3, 2);
plot(pred_var_delta_mu);
title("Predicted variance");
subplot(1, 3, 3);
plot(pred_var_delta_mu, emp_var_delta_mu, "k.");
xlabel("Predicted");
ylabel("Empirical");
linkaxes([ax1, ax2]);
title("Empirical vs. Predicted");

% Expected confidence
figure;
ax1 = subplot(1, 3, 1);
plot(emp_exp_confidence);
title("Empirical confidence");
ax2 = subplot(1, 3, 2);
plot(pred_exp_confidence);
title("Predicted confidence");
subplot(1, 3, 3);
plot(pred_exp_confidence, emp_exp_confidence, "k.");
xlabel("Predicted");
ylabel("Empirical");
linkaxes([ax1, ax2]);
title("Empirical vs. Predicted");

% Expected value of control
figure;
ax1 = subplot(1, 3, 1);
plot(emp_exp_value_control);
title("Empirical value of control");
ax2 = subplot(1, 3, 2);
plot(pred_exp_value_control);
title("Predicted value of control");
subplot(1, 3, 3);
plot(pred_exp_value_control, emp_exp_value_control, "k.");
xlabel("Predicted");
ylabel("Empirical");
linkaxes([ax1, ax2]);
title("Empirical vs. Predicted");


%% 1 - Online MCD: optimal stopping rule

T = 100;
kappa = 1 / T;
alpha = 0.0005;