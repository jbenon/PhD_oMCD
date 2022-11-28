% Compute information used to train the network, based on cue positions
% and ranks.

function CueSamples = expandCueSamplesParametric(CueSamples, k)
% Parameters
% ----------
% CueSamples: structure
% Defines a history of cue sampled during a session.
%   .i_trial: double
%       Trial index.
%   .i_step: double
%       Step index.
%   .cue_pos: double
%       Position (1-4) of the sampled cue.
%   .cue_rank: double
%       Rank (1-5) of the sampled cue.
%
% k: double
%   Metacognitive control of decision parameter for effort (cost of
%   sampling another cue).
%
% Output
% ------
% CueSamples: structure
% Contains all the information of a session, step by step.
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Trial index.
%   .trial_type: [1 x n_samples] "undefined" / "option" / "attribute"
%       If at least two cues were sampled during the trial, it can be
%       either an option trial (two first cues belong to the same option)
%       or an attribute trial (two first cues represent the same
%       attribute). If only one cue was sampled, the trial type is
%       undefined.
%   .cue_rank: [1 x n_samples] 1 / 2 / 3 / 4 / 5
%       Rank (1-5) of the attended cue.
%   .cue_type: [1 x n_samples] -1 / 1
%       Type (probability/magnitude) of the attended cue.
%   .option_loc: [1 x n_samples] -1 / 1
%       Localization (left/right) of the attended cue.
%   .option_order: [1 x n_samples] 1 / 2
%       Order of attendance (first/second) of the attended option within
%       the current trial.
%   .prob_attended: [1 x n_samples] double
%       Estimated probability of the attended cue.
%   .mag_attended: [1 x n_samples] double
%       Estimated magnitude of the attended cue.
%   .value_attended: [1 x n_samples] double
%       Estimated value of the attended option.
%   .value_unattended: [1 x n_samples] double
%       Estimated value of the unattended option.
%   .value_diff_attended: [1 x n_samples] double
%       Difference between the estimated values of the attended and
%       unattended options.
%   .value_left: [1 x n_samples] double
%       Estimated value of the left option.
%   .value_right: [1 x n_samples] double
%       Estimated value of the right option.
%   .value_diff_loc: [1 x n_samples] double
%       Difference between the estimated values of the left and right
%       options.
%   .value_first: [1 x n_samples] double
%       Estimated value of the firstly attended option.
%   .value_second: [1 x n_samples] double
%       Estimated value of the secondly attended option.
%   .value_diff_order: [1 x n_samples] double
%       Difference between the estimated values of the firstly and
%       secondly attended options.
%   .value_t: [1 x n_samples] double
%       Estimated value attended at step t.
%   .value_t_1: [1 x n_samples] double
%       Estimated value attended at step t-1.
%   .value_t_2: [1 x n_samples] double
%       Estimated value attended at step t-2.
%.  choice_confidence: [1 x n_samples] double
%       Choice confidence (0-1);
%   .stop_cont: [1 x n_samples] double
%       Stop/continue signal (-1 - 1).


%% Get session information
n_trials = CueSamples.i_trial(end);
n_samples = length(CueSamples.i_trial);


%% Compute attended cue and option information

% === Attended cue type === %

%{
Cue positions:
1: left probability
2: left magnitude
3: right probability
4: right magnitude
%}
% Initialize all types to 1 (magnitude)
CueSamples.cue_type = ones(1, n_samples);
% Update concerned types to -1 (probability)
CueSamples.cue_type((CueSamples.cue_pos == 1)) = -1;
CueSamples.cue_type((CueSamples.cue_pos == 3)) = -1;

% === Attended option localization (left/right) === %

% Initialize all locations to 1 (right)
CueSamples.option_loc = ones(1, n_samples);
% Update concerned locations to -1 (left)
CueSamples.option_loc((CueSamples.cue_pos == 1)) = -1;
CueSamples.option_loc((CueSamples.cue_pos == 2)) = -1;

% === Attended option identity (first/second) === %

% Initialize all orders to 1 (first)
CueSamples.option_order = NaN(1, n_samples);
no_sample_start_trial = 1;
for i_trial = unique(CueSamples.i_trial)
    % Get number of attended cues during the trial
    n_steps_trial = max(CueSamples.i_step(CueSamples.i_trial == i_trial));
    % Compute the indices of the starting and ending samples
    no_sample_end_trial = no_sample_start_trial + n_steps_trial - 1;
    range_sample_trial = no_sample_start_trial:no_sample_end_trial;
    % Initialize local ordering of options
    option_order = ones(1, n_steps_trial);
    % Define the first option attended
    option_first = CueSamples.option_loc(no_sample_start_trial);
    % Update concerned orders to 2 (second)
    option_order(CueSamples.option_loc(range_sample_trial) ~= option_first) = 2;
    % Save info in the output structure
    CueSamples.option_order(range_sample_trial) = option_order;
    % Update next trial start
    no_sample_start_trial = no_sample_start_trial + n_steps_trial;
end

% === Trial type (option/attribute) === %

% Initialize all trial types
CueSamples.trial_type = repmat("undefined", 1, n_samples);
no_sample_start_trial = 1;
for i_trial = unique(CueSamples.i_trial)
    % Get number of attended cues during the trial
    n_steps_trial = max(CueSamples.i_step(CueSamples.i_trial == i_trial));
    % Compute the indices of the starting and ending samples
    no_sample_end_trial = no_sample_start_trial + n_steps_trial - 1;
    range_sample_trial = no_sample_start_trial:no_sample_end_trial;
    % Update trials with at least two cues sampled
    if n_steps_trial >= 2
        % Option trial
        if CueSamples.option_loc(no_sample_start_trial) == ...
           CueSamples.option_loc(no_sample_start_trial + 1)
            CueSamples.trial_type(range_sample_trial) = "option";
        % Attribute trial
        elseif CueSamples.cue_type(no_sample_start_trial) == ...
               CueSamples.cue_type(no_sample_start_trial + 1)
            CueSamples.trial_type(range_sample_trial) = "attribute";
        end
    end
    % Update next trial start
    no_sample_start_trial = no_sample_start_trial + n_steps_trial;
end


%% Compute estimated attributes

% === Initialize storing variables ===%

% Attended/unattended
prob_attended = NaN(1, n_samples);
mag_attended = NaN(1, n_samples);
prob_unattended = NaN(1, n_samples);
mag_unattended = NaN(1, n_samples);
% Left/right
prob_left = NaN(1, n_samples);
mag_left = NaN(1, n_samples);
prob_right = NaN(1, n_samples);
mag_right = NaN(1, n_samples);
% First/second
prob_first = NaN(1, n_samples);
mag_first = NaN(1, n_samples);
prob_second = NaN(1, n_samples);
mag_second = NaN(1, n_samples);

% === Compute estimates trial per trial === %

no_sample_start_trial = 1;
for i_trial = unique(CueSamples.i_trial)
    % Get number of attended cues during the trial
    n_steps_trial = max(CueSamples.i_step(CueSamples.i_trial == i_trial));
    % Define sample indices
    no_sample_end_trial = no_sample_start_trial + n_steps_trial - 1;
    % Default cue ranks [P left, M left, P right, M right]
    known_cue_ranks = [3, 3, 3, 3]; 
    % First attended option
    option_first = CueSamples.option_loc(no_sample_start_trial);

    for i_step = 1:n_steps_trial

        % Update current knowledge on trial cue ranks
        i_sample = no_sample_start_trial + i_step - 1;
        known_cue_ranks(CueSamples.cue_pos(i_sample)) = CueSamples.cue_rank(i_sample);
     
        % Update estimated left/right attributes
        prob_left(i_sample) = known_cue_ranks(1);
        mag_left(i_sample) = known_cue_ranks(2);
        prob_right(i_sample) = known_cue_ranks(3);
        mag_right(i_sample) = known_cue_ranks(4);

        % Update estimated first/second attributes
        if option_first == -1 % first option is on the left
            prob_first(i_sample) = prob_left(i_sample);
            mag_first(i_sample) = mag_left(i_sample);
            prob_second(i_sample) = prob_right(i_sample);
            mag_second(i_sample) = mag_right(i_sample);
        else % first option is on the right
            prob_first(i_sample) = prob_right(i_sample);
            mag_first(i_sample) = mag_right(i_sample);
            prob_second(i_sample) = prob_left(i_sample);
            mag_second(i_sample) = mag_left(i_sample);
        end

        % Update estimated attended/unattended option
        if CueSamples.option_loc(i_sample) == -1 % attended option is on the left
            prob_attended(i_sample) = prob_left(i_sample);
            mag_attended(i_sample) = mag_left(i_sample);
            prob_unattended(i_sample) = prob_right(i_sample);
            mag_unattended(i_sample) = mag_right(i_sample);
        else % attended option is on the right
            prob_attended(i_sample) = prob_right(i_sample);
            mag_attended(i_sample) = mag_right(i_sample);
            prob_unattended(i_sample) = prob_left(i_sample);
            mag_unattended(i_sample) = mag_left(i_sample);
        end
    end
    % Update next trial start
    no_sample_start_trial = no_sample_start_trial + n_steps_trial;
end

% Save info in the structure
CueSamples.prob_left = rankToProbability(prob_left);
CueSamples.mag_left = rankToMagnitude(mag_left);
CueSamples.prob_right = rankToProbability(prob_right);
CueSamples.mag_right = rankToMagnitude(mag_right);
CueSamples.prob_first = rankToProbability(prob_first);
CueSamples.mag_first = rankToMagnitude(mag_first);
CueSamples.prob_second = rankToProbability(prob_second);
CueSamples.mag_second = rankToMagnitude(mag_second);
CueSamples.prob_attended = rankToProbability(prob_attended);
CueSamples.mag_attended = rankToMagnitude(mag_attended);
CueSamples.prob_unattended = rankToProbability(prob_unattended);
CueSamples.mag_unattended = rankToMagnitude(mag_unattended);


%% Compute option estimated values

% Value of the attended/unattended option
CueSamples.value_attended = CueSamples.prob_attended .* ...
    CueSamples.mag_attended;
CueSamples.value_unattended = CueSamples.prob_unattended .* ...
    CueSamples.mag_unattended;
CueSamples.value_diff_attended = CueSamples.value_attended - ...
    CueSamples.value_unattended;

% Value of the left/right option
CueSamples.value_left = CueSamples.prob_left .* ...
    CueSamples.mag_left;
CueSamples.value_right = CueSamples.prob_right .* ...
    CueSamples.mag_right;
CueSamples.value_diff_loc = CueSamples.value_left - ...
    CueSamples.value_right;

% Value of the first/second option
CueSamples.value_first = CueSamples.prob_first .* ...
    CueSamples.mag_first;
CueSamples.value_second = CueSamples.prob_second .* ...
    CueSamples.mag_second;
CueSamples.value_diff_order = CueSamples.value_first - ...
    CueSamples.value_second;

% === Temporal estimation of values === %

% Compute default value
value_default = rankToProbability(3) * rankToMagnitude(3);
% Value attended at step t
CueSamples.value_t = CueSamples.value_attended;
% Initialize value attended at step t-1 and t-2
CueSamples.value_t_1 = CueSamples.value_t;
CueSamples.value_t_2 = CueSamples.value_t;
% Destroy information regarding the last attended values
CueSamples.value_t_1(CueSamples.i_step == 4) = value_default;
CueSamples.value_t_2(CueSamples.i_step == 3) = value_default;
CueSamples.value_t_2(CueSamples.i_step == 4) = value_default;
% Shift information
CueSamples.value_t_1 = [value_default, ...
                         CueSamples.value_t_1(1:(end-1))];
CueSamples.value_t_2 = [value_default, ...
                         value_default, ...
                         CueSamples.value_t_2(1:(end-2))];


%% Stop/continue signal

% Metacognitive control parameter: confidence probability
s = 0.09;
% s = std(CueSamples.value_attended);

% Compute choice confidence at each step
CueSamples.choice_confidence = VBA_sigmoid(abs(CueSamples.value_attended - CueSamples.value_unattended) / s);
% Initialize stop/continue signals
CueSamples.stop_cont = NaN(1, n_samples);
for i_trial = unique(CueSamples.i_trial)
    % Focus on the trial of interest
    select_trial = (CueSamples.i_trial == i_trial);
    % Choice confidence at step 0 is set to 0.5
    CueSamples.stop_cont((CueSamples.i_step == 1) & select_trial) = ...
        CueSamples.choice_confidence((CueSamples.i_step == 1) & select_trial)...
        - 0.5...
        - k;
    % Get number of cues sampled in the trial
    n_steps_trial = sum(select_trial);
    % Compute improvement in choice confidence at each next time step
    for i_step = 2:n_steps_trial
        CueSamples.stop_cont((CueSamples.i_step == i_step) & select_trial) = ...
            CueSamples.choice_confidence((CueSamples.i_step == i_step) & select_trial) ...
            - CueSamples.choice_confidence((CueSamples.i_step == (i_step - 1)) & select_trial) ...
            - k;
    end
end

end
