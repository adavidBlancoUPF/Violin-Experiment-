function chord_name = triad_to_short_chord_name(triad)
%
% function chord_name = triad_to_short_chord_name(triad)
% 
% A utility function to convert from a triad index - as defined in
% define_music_globals.m - to a friendly name, suitable for printing.
%

define_music_globals;

if (triad == TRIAD_MAJOR)
    chord_name = '';
    return
end

if (triad == TRIAD_MINOR)
    chord_name = 'm';
    return
end

if (triad == TRIAD_DIMINISHED)
    chord_name = 'dim';
    return
end

if (triad == TRIAD_AUGMENTED)
    chord_name = 'aug';
    return
end

if (triad == TRIAD_SUSPENDED)
    chord_name = 'sus';
    return
end

% unknown triad
chord_name = '?';
return
