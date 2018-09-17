function [pitch_index,octave] = get_note_info(note_struct)
%
% function [pitch_index,octave] = get_note_info(note_struct)
%
% Extracts the pitch index (0 --> 11) and octave number from the xml
% struct corresponding to a MusicXML note element.

n = note_struct;
p = getelements(n,'pitch');

% This doesn't look like a note...
if (isempty(p))
    pitch_index = -1;
    octave = -1;
    return;
end

octave_struct = getelements(p,'octave');
octave = sscanf(octave_struct.sub(1).data,'%d');

step_struct = getelements(p,'step');
pitch_name = lower(step_struct.sub(1).data);
pitch_index = note_index_from_name(pitch_name);

% Now look for a sharp or flat...
pitch_alter = 0;
alter_struct = getelements(p,'alter');
if (~isempty(alter_struct))
    pitch_alter = sscanf(alter_struct.sub(1).data,'%d');
end

% Now collect that information into a single pitch index
% and octave (we don't care about maintaining the notation
% of sharps and flats)
pitch_index = pitch_index + pitch_alter;
if (pitch_index < 0)
    pitch_index = pitch_index + 12;
    octave = octave - 1;
end;
if (pitch_index > 12)
    pitch_index = pitch_index - 12;
    octave = octave + 1;
end;
