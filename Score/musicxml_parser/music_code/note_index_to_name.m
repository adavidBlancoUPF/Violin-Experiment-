function name = note_index_to_name(index)
%
% function name = note_index_to_name(index)
%
% Returns a friendly name for the note at index [index], where
% an index ranges from 0 (C) to 11 (B)
%

define_music_globals;

name = sharp_key_names{index+1};