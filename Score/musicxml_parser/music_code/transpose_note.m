function [pitch_index, octave] = transpose_note(pitch_index, octave, input_key, output_key)
%
% function [pitch_index, octave] = transpose_note(pitch_index, octave, input_key, output_key)
%
% Transposes a single note or set of notes from the input key to the output key 
% (both are key indices, with 0=c and 12=b).  pitch_index is also an index from
% 0 --> 12.
%

shift_to_apply = output_key - input_key;
pitch_index = pitch_index + shift_to_apply;

high_pitch_indices = find(pitch_index > 12);
pitch_index(high_pitch_indices) = pitch_index(high_pitch_indices) - 12;
octave(high_pitch_indices) = octave(high_pitch_indices) + 1;

low_pitch_indices = find(pitch_index < 0);
pitch_index(low_pitch_indices) = pitch_index(low_pitch_indices) + 12;
octave(low_pitch_indices) = octave(low_pitch_indices) - 1;

% if (pitch_index > 12)
%     pitch_index = pitch_index - 12;
%     octave = octave + 1;
% elseif (pitch_index < 0)
%     pitch_index = pitch_index + 12;
%     octave = octave - 1;
% end


