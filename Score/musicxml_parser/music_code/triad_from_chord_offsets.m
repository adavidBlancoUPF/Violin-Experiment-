function triad = triad_from_chord_offsets(offsets)
%
% function triad = triad_from_chord_offsets(offsets)
% 
% A utility function to extract a triad index - as defined in
% define_music_globals.m - from a set of note indices that make up a chord.
% For example, the indices [0 4 7] represent [C E G] in the key of C, so
% this is a major chord.  You'll get TRIAD_UNKNOWN if you supply something
% that's not a standard triad, e.g. [0 1 2].
%

define_music_globals;

if (length(intersect(offsets,[0 4 7])) == 3)
    triad = TRIAD_MAJOR;
    return;
end

if (length(intersect(offsets,[0 3 7])) == 3)
    triad = TRIAD_MINOR;
    return;
end

if (length(intersect(offsets,[0 3 6])) == 3)
    triad = TRIAD_DIMINISHED;
    return;
end

if (length(intersect(offsets,[0 4 8])) == 3)
    triad = TRIAD_AUGMENTED;
    return;
end

if (length(intersect(offsets,[0 5 7])) == 3)
    triad = TRIAD_SUSPENDED;
    return;
end

% fprintf(1,'Unknown triad: ');
% for(i=1:length(offsets))
%     fprintf(1,'%d ',offsets(i));
% end
% fprintf(1,'\n');
triad = TRIAD_UNKNOWN;
return;