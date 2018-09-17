function [notes,offsets] = alter_chord_notes(notes,offsets,alter)
%
% function [notes,offsets] = alter_chord_notes(notes,offsets,alter)
%
% Returns the notes corresponding to this chord, after performing a
% specified alteration to a single scale degree.
%
% 'notes' is a list of MIDI note numbers (input and output).
%
% 'offsets' is a list of chromatic degrees away from the chord root
% (input and output).
%
% The 'alter' parameter should have two entries, specifying the chord
% degree to alter (1) and the alteration to perform (2).


% These are the only indices we can "alter" in a named chord
degrees = [1 3 5 7 9 11 13];
index = find(degrees == alter(1));

if ((isempty(index)) || (index > length(offsets)))
    fprintf(1,'Unable to alter degree %d of chord\n',alter(1));
else
    notes(index) = notes(index) + alter(2);
    offsets(index) = offsets(index) + alter(2);
end
