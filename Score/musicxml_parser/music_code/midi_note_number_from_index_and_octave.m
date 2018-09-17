function notenumber = midi_note_number_from_index_and_octave(pitch_index,octave)
%
% function notenumber =
%   midi_note_number_from_index_and_octave(pitch_index,octave)
%
% Returns a standard MIDI note number from a MIDI octave number and
% a pitch index (a number from 0 (C) to 11 (B)
%

notenumber = (octave+1)*12 + pitch_index;