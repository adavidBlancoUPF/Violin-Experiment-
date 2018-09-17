function [notes,offsets] = get_chord_notes(chord_root_index,chord_root_octave,chord_name)
%
% function [notes,offsets] = get_chord_notes(chord_root_index,chord_root_octave,chord_name)
%
% Returns midi notes and root offsets for all notes in the specified chord.
%
% Parameters:
% 
% chord_root_index: the root note of the chord, from 0 (C) --> 11 (B)
%
% chord_root_octave: the MIDI octave number the chord should be expanded in
%
% chord_name: the string name of the chord extension, e.g. "major" or
% "dominant-ninth"
%

offsets = [];

if (strcmp(chord_name,'major'))
    offsets = [0 4 7];
elseif(strcmp(chord_name,'major-sixth'))
    offsets = [0 4 7 9];
elseif (strcmp(chord_name,'major-seventh'))
    offsets = [0 4 7 11];
elseif (strcmp(chord_name,'major-ninth'))
    offsets = [0 4 7 11 14];
elseif (strcmp(chord_name,'maj69'))
    offsets = [0 4 7 9 14];
elseif (strcmp(chord_name,'major-11th'))
    offsets = [0 4 7 11 14 17];
elseif (strcmp(chord_name,'major-13th'))
    offsets = [0 4 7 11 14 17 21];
elseif (strcmp(chord_name,'major-minor'))
    offsets = [0 4 7 11];

elseif (strcmp(chord_name,'min'))
    offsets = [0 3 7];
elseif (strcmp(chord_name,'minor'))
    offsets = [0 3 7];
elseif (strcmp(chord_name,'minor-sixth'))
    % Most sources define the m6 chord as using the major (non-flat) sixth note
    offsets = [0 3 7 9];
elseif (strcmp(chord_name,'minor-seventh'))
    offsets = [0 3 7 10];
elseif (strcmp(chord_name,'minor-ninth'))
    offsets = [0 3 7 10 14];
elseif (strcmp(chord_name,'minor-eleventh'))
    offsets = [0 3 7 10 14 17];
elseif (strcmp(chord_name,'minor-11th'))
    offsets = [0 3 7 10 14 17];
elseif (strcmp(chord_name,'minor-13th'))
    offsets = [0 3 7 10 14 17 21];

elseif(strcmp(chord_name,'dominant'))
    offsets = [0 4 7 10];
elseif(strcmp(chord_name,'dominant-seventh'))
    offsets = [0 4 7 10];
elseif(strcmp(chord_name,'dominant-ninth'))
    offsets = [0 4 7 10 14];
elseif(strcmp(chord_name,'dominant-eleventh'))
    offsets = [0 4 7 10 14 17];
elseif(strcmp(chord_name,'dominant-11th'))
    offsets = [0 4 7 10 14 17];
elseif(strcmp(chord_name,'dominant-13th'))
    offsets = [0 4 7 10 14 17 21];

elseif(strcmp(chord_name,'augmented'))
    offsets = [0 4 8];
elseif(strcmp(chord_name,'augmented-seventh'))
    offsets = [0 4 8 10];

elseif(strcmp(chord_name,'diminished'))
    offsets = [0 3 6];
elseif(strcmp(chord_name,'diminished-seventh'))
    offsets = [0 3 6 9];
elseif(strcmp(chord_name,'half-diminished'))
    offsets = [0 3 6 10];

elseif(strcmp(chord_name,'suspended-fourth'))
    offsets = [0 5 7];
elseif(strcmp(chord_name,'suspended-second'))
    offsets = [0 2 7];

else
    fprintf(1,'Error: unknown chord name %s\n',chord_name);
    offsets = [0];
end

notes = chord_root_index+offsets;
notes = midi_note_number_from_index_and_octave(notes,chord_root_octave);

