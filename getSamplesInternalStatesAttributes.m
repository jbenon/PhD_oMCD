% Returns the array of internal states at each step of sampled trials, i.e.
% which attribute has been sampled and what is the value of known
% attributes.

function state_attribute = getSamplesInternalStatesAttributes(CueSamples)
% Parameters
% ----------
% CueSamples: structure
%   .i_trial: [1 x n_samples] double
%       Trial index.
%   .i_step: [1 x n_samples] double
%       Step index.
%   .cue_pos: [1 x n_samples] double
%       Position (1-4) of the sampled cue.
%   .cue_rank: [1 x n_samples] double
%       Rank (1-5) of the sampled cue.
%
% Outputs
% -------
% state_attribute: [4 x n_samples] double
%   Each column describes the state of a sample: the known value of the
%   left probability, left magnitude, right probability and left magnitude.
%   The unknown attributes are replaced with NaN.


% Get samples dimensions
n_trials = CueSamples.i_trial(end);
n_samples = length(CueSamples.i_trial);

% Initialize trial states
state_attribute = NaN(4, n_samples);

% === Loop over trials === %
for i_trial = 1:n_trials
    % Default cue ranks [P left, M left, P right, M right]
    known_cue_ranks = NaN(1,4);

    % === Loop over trial steps === %
    for i_step = 1:4
        % Update current knowledge on trial cue ranks
        i_sample = (i_trial - 1) * 4 + i_step;
        known_cue_ranks(CueSamples.cue_pos(i_sample)) = ...
            CueSamples.cue_rank(i_sample);
        % Update estimated left probability
        state_attribute(1, i_sample) = rankToProbability(...
            known_cue_ranks(1));
        % Update estimated left magnitude
        state_attribute(2, i_sample) = rankToMagnitude(...
            known_cue_ranks(2));
        % Update estimated right probability
        state_attribute(3, i_sample) = rankToProbability(...
            known_cue_ranks(3));
        % Update estimated right magnitude
        state_attribute(4, i_sample) = rankToMagnitude(...
            known_cue_ranks(4));
    end
end

end
