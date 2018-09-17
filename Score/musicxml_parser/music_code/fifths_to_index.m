function [keyindex,keyname] = fifths_to_index(fifths)
%
% function [keyindex,keyname] = fifths_to_index(fifths)
%
% Converts a key index in fifths (0==C, 1==G, etc.) to a key
% index from 0 (C) to 11 (B).
%
% The 'fifths' system is used in MusicXML files.

define_music_globals;

keyindex = 0 - (fifths * 5);
while(keyindex < 0)
    keyindex = keyindex + 12;
end
while(keyindex > 12)
    keyindex = keyindex - 12;
end

if (fifths > 0)
    keyname = sharp_key_names{keyindex+1};
else
    keyname = flat_key_names{keyindex+1};
end

