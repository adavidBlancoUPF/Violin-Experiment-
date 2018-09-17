%
% function [notes, chords, chord_names] = ...
%    transpose_notes_and_chords(notes, chords, chord_names, input_key,
%    output_key)
%
% Takes:
%
% notes,chords,chord_names: see the output of get_notes_and_chords.m
%
% input_key: an index from 0 (c) to 12 (b) indicating the input (major)
% key.  Contained in the 'info' structure returned from
% get_notes_and_chords.  If this is an array, key_change_indicies should
% specify the measure indices where key changes occur.
%
% output_key: an index from 0 (c) to 12 (b) indicating the output (major)
% key.  _All_ sections will be transposed to this key.  
% -1 indicates no transposition.
%
% key_change_indices: measure indices (0 is the beginning of the first
% measure, 1 is the end of the first measure) where key changes occur.
% Ignored if input_key is scalar.
%
% Returns:
%
% notes,chords,chord_names: see the output of get_notes_and_chords.m
%
function [notes, chords, chord_names] = ...
    transpose_notes_and_chords(notes, chords, chord_names, input_key, output_key, ...
    key_change_indices)

define_music_globals;

% Don't need to do any transposition...
if ((length(input_key) == 1) && (input_key == output_key)) 
    % fprintf(1,'Null transposition op (from %d to %d), skipping...\n', input_key, output_key);
    return; 
end

% Make recursive calls to transpose key-changed regions...
if (length(input_key) > 1)
    
    % Find the indices of each changed region (skipping the initial key)
    for(i=2:length(key_change_indices))
       key_start_measure =  key_change_indices(i);
       
       % Where is the _next_ key change?
       if (i == length(key_change_indices))
           next_key_start_measure = Inf;
       else
           next_key_start_measure = key_change_indices(i+1);
       end
       
       % Find all note and chord events that happen during this key change
       note_indices = ...
           find(notes(:,1) >= key_start_measure & notes(:,1) <= next_key_start_measure);
       chord_indices = ...
           find(chords(:,1) >= key_start_measure & chords(:,1) <= next_key_start_measure);
       notes_to_adjust = notes(note_indices,:);
       chords_to_adjust = chords(chord_indices,:);
       chord_names_to_adjust = chord_names(chord_indices,:);
       
       % We want to transpose this chunk _to_ our main input key
       local_output_key = input_key(1);
       local_output_key_name = sharp_key_names{local_output_key+1};
       
       % The input key here is whatever we changed to
       local_input_key = input_key(i);
       local_input_key_name = sharp_key_names{local_input_key+1};
       
       %fprintf(1,'Key change detected: transposing beats %d to %d from %s to %s\n',...
         %   key_start_measure, next_key_start_measure, ...
         %  local_input_key_name, local_output_key_name);
       
       % Make the recursive call
       [adjusted_notes, adjusted_chords, adjusted_chord_names] = ...
           transpose_notes_and_chords(notes_to_adjust, chords_to_adjust, ...
           chord_names_to_adjust, local_input_key, local_output_key);
       
       % Stick them back into our main matrix
       notes(note_indices,:) = adjusted_notes;
       chords(chord_indices,:) = adjusted_chords;
       chord_names(chord_indices,:) = adjusted_chord_names;
    end
    
    % Smush the keys together...
    input_key = input_key(1);
    
end

% At this point, input_key should be a scalar...
if (length(input_key) > 1)
    fprintf(1,'\n\nError: I failed to recursively change keys...\n\n');
    return;
end

% Now do the actual transposition...

% Transpose notes first...
pitch_index = notes(:,3);
octave = notes(:,4);

[pitch_index,octave] = transpose_note(pitch_index,octave,input_key,output_key);

notes(:,3) = pitch_index;
notes(:,4) = octave;

% Now chords...
chord_pitch_index = chords(:,3);
chord_octave = chords(:,4);

[chord_pitch_index,chord_octave] = transpose_note(chord_pitch_index,chord_octave,input_key,output_key);

chords(:,3) = chord_pitch_index;
                