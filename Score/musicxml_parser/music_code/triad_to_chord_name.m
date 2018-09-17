function chord_name = triad_to_chord_name(triad)
%
% function chord_name = triad_to_chord_name(triad)
% 
% A utility function to convert from a triad index - as defined in
% define_music_globals.m - to a friendly name, suitable for printing.
%

define_music_globals;

if (triad == TRIAD_MAJOR)
    chord_name = 'major';
    return
end

if (triad == TRIAD_MINOR)
    chord_name = 'minor';
    return
end

if (triad == TRIAD_DIMINISHED)
    chord_name = 'diminished';
    return
end

if (triad == TRIAD_AUGMENTED)
    chord_name = 'augmented';
    return
end

if (triad == TRIAD_SUSPENDED)
    chord_name = 'suspended-fourth';
    return
end

if (triad == TRIAD_UNKNOWN)
    chord_name = 'unknown';
    return
end