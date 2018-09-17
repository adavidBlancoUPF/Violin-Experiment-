function chord_name = get_chord_name(chord_index)
%
% function chord_name = get_chord_name(chord_index)
%
% Gets a useful name, such as "Amin", from a 1-->60 index
%
% 1 should be Cmaj
% 60 should be Bsus

define_music_globals;

% Make it go from 0 --> 59 instead of 1-->60
chord_index = chord_index -1;

% From 0 --> 11
root = floor(chord_index / NUM_TRIADS);

% From 0 --> 4
triad = mod(chord_index, NUM_TRIADS);

chord_name = [upper(sharp_key_names{root+1}) triad_names{triad+1}];