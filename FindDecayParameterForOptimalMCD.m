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
n_steps = max(DataSamples.i_step);

%%

% === Prepare exploration of parameters === %

% All possible values for the parameter k
all_k = 0.01:0.002:0.02;
n_k = length(all_k);
% Initialize figure
figure("Position", [100, 50, 400, 900]);
% Initialize subplot index
i_plot = 1;

% === Loop over possible effort parameters === %
for k = all_k

    % === Compute value of control === %
    
    % Initialize VC storage
    DataSamples.value_control = NaN(1, n_samples);
    DataSamples.stop_step_optimal = NaN(1, n_samples);
    % Initialize sample index
    i_sample = 1;
    % === Loop over trials === %
    for i_trial = 1:n_trials
        % === Loop over trial steps === %
        for i_step = 1:n_steps
            % Compute the current value of control
            DataSamples.value_control(i_sample) = ...
                DataSamples.choice_confidence(i_sample) - k* i_step;
            % Update the sample index
            i_sample = i_sample + 1;
        end
        % Optimal stopping step
        i_samples_trial = (i_sample - n_steps):(i_sample - 1);
        step_decision_optimal = find(...
            DataSamples.value_control(i_samples_trial) == ...
            max(DataSamples.value_control(i_samples_trial)));
        DataSamples.stop_step_optimal(i_samples_trial) = step_decision_optimal(1);
    end

    % === Plot histogram of decision steps === %

    % Define subplot
    subplot(n_k, 1, i_plot);
    i_plot = i_plot + 1;
    % Plot normalized histogram
    h = histogram(DataSamples.stop_step_optimal(1:4:end), ...
        "Normalization", "probability");
    xticks(1:4)
    % Get distribution entropy
    entropy = - sum (h.Values .* log(h.Values));
    % Write pseudo inverse entropy
    title(sprintf("For k = %0.3f, entropy = %0.3f", k, entropy));
    % Axis label
    if k == all_k(end)
        xlabel("Optimal decision step");
    end
end
