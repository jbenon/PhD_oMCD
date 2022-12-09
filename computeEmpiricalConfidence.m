% Computes the empirical confidence at each sampled cue: probability that
% the currently best option stays the best option at the end of the trial.

function confidence = computeEmpiricalConfidence(DataSamples, ...
    state, best_option)
% Parameters
% ----------
% DataSamples: structure
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Trial index.
%   .value_left: [1 x n_samples] double
%       Estimated value of the left option.
%   .value_right: [1 x n_samples] double
%       Estimated value of the right option.
% state: [4 x n_samples] double
%   Each column describes the state of a sample: the known rank of the left
%   probability, left magnitude, right probability and left magnitude. The
%   unknown attributes are replaced with NaN.
% best_option: [1 x n_trials] string
%   Stores which option was the best at the end of each trial: "left",
%   "right" or "both".
%
% Outputs
% -------
% confidence: [1 x n_samples] double
%   Probability that the option being currently the best stays the best at
%   the end of trial.


% Get samples dimensions
n_trials = DataSamples.i_trial(end);
n_samples = length(DataSamples.i_trial);

% Initialize output
confidence = NaN(1, n_samples);

% Replaces the NaN by 0 to enable comparison between internal states
state(isnan(state)) = 0;

% === Loop over trials === %
for i_trial = 1:n_trials

    % === Loop over trial steps === %
    for i_step = 1:4
        % Define the sample index
        i_sample = (i_trial - 1) * 4 + i_step;

        % === Gather the outcomes of trials with the same state === %

        % Find samples with the same state
        select_samples = all((state == state(:, i_sample)));
        % Select trials containing the same state
        i_select_trials = DataSamples.i_trial(select_samples);
        % Count the number of trials in the same state where each option
        % ended up being a good decision
        n_left_good = sum(strcmp(best_option(i_select_trials), "left"));
        n_right_good = sum(strcmp(best_option(i_select_trials), "right"));
        n_both_good = sum(strcmp(best_option(i_select_trials), "both"));
        % Compute the proportion of trials in the same state where each
        % option ended up being a good decision 
        n_same_state = n_left_good + n_right_good + n_both_good;
        prop_left_good = (n_left_good + n_both_good) / n_same_state;
        prop_right_good = (n_right_good + n_both_good) / n_same_state;

        % === Store confidence depending on the current best option === %

        % If the current best option is the left
        if DataSamples.value_left(i_sample) > ...
                DataSamples.value_right(i_sample)
            confidence(i_sample) = prop_left_good;
        % If the current best option is the right
        elseif DataSamples.value_left(i_sample) < ...
                DataSamples.value_right(i_sample)
            confidence(i_sample) = prop_right_good;
        % If no option is the best
        else
            % If this is the last step: confidence = 100 %
            if i_step == 4
                confidence(i_sample) = 1;
            % Else, compute the expected confidence
            else
                confidence(i_sample) = ...
                    mean([prop_left_good, prop_right_good]);
            end
        end
    end
end

end
