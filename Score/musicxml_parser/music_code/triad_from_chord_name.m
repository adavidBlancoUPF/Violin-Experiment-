function triad = triad_from_chord_name(chord_name)
%
% function triad = triad_from_chord_name(chord_name)
%
% Utility function to produce a triad index - as defined in
% define_music_globals.m - from a friendly chord name.
%

define_music_globals;

if (~isempty(strfind(chord_name,'major')) | ~isempty(strfind(chord_name,'dominant')))
    triad = TRIAD_MAJOR;
    return;
end

if (~isempty(strfind(chord_name,'minor')))
    triad = TRIAD_MINOR;
    return;
end

if (~isempty(strfind(chord_name,'diminished')))
    triad = TRIAD_DIMINISHED;
    return;
end

if (~isempty(strfind(chord_name,'augmented')))
    triad = TRIAD_AUGMENTED;
    return;
end

if (~isempty(strfind(chord_name,'suspended')))
    triad = TRIAD_SUSPENDED;
    return;
end

% fprintf(1,'\n\nUnknown triad: %s\n\n',chord_name);
triad = TRIAD_UNKNOWN;
return;