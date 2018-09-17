function [notes, chords, chord_names, info, lyrics] = get_notes_and_chords(measures)
%
% function [notes, chords, chord_names, info] = get_notes_and_chords(measures)
%
% Extracts note and chord information from a list of measure structures (as
% obtained from a MusicXML file).  This is where most of the deep MusicXML
% parsing takes place.
%
% Takes:
%
% measures: a struct array of measures as produced by process_xml_data.
%
% Returns:
%
% 'notes' is a matrix of size n_notes x 4, with the four columns as follows:
%
%   [start] [end] [pitch] [octave]
%
%   start and end are in units of 'measure', so 0 is the beginning of the
%   first measure and 1 is the end of the first measure.
% 
%   pitch is a pitch index (0 = c, 11 = b), and octave indicates the octave relative
%   to middle-c.
%
% 'chords' has the same four columns, plus a fifth column indicating
% which triad this chord is based on (see define_music_globals.m).
%
% 'chord_names' is an n_notes x 1 cell array indicating the full name of each chord.
%
% 'info' has a bunch of other metadata, like time and key information.  It
% also contains an "error" field, which is >=0 if everything goes well, <0 
% to indicate en error, in which case the other fields will be empty.
%
% 'lyrics' is a struct array of lyric information, where each element is a
% struct corresponding to a syllable, of this format:
%
% struct lyric {
%   % The text corresponding to this syllable
%   string text;
%   % An indicator of where this syllable sits in a word
%   SYLLABLE_* word_position;
%   % Which note in the notes array does this syllable correspond to?
%   int note_index;
%   % If there are multiple lyrics for this note (probably multiple
%   % verses), which one is this?
%   int lyric_number;
% };
%


%%

DEFAULT_CHORD_OCTAVE = 3;
EPSILON = 0.0000001;

define_music_globals;

% Set up return values
notes = zeros(0,4);
chords = zeros(0,5);
chord_names = cell(0);
lyrics = [];
info.error = 0;

% Find the attributes tag
attributes_index = find(strcmp({measures(1).sub.name},'attributes'));
if (length(attributes_index) ~= 1) fprintf(1,'Oops... illegal attributes tag...\n'); end;
attributes_struct = measures(1).sub(attributes_index);

% Find division information
divisions_index = find(strcmp({attributes_struct.sub.name},'divisions'));
divisions_struct = attributes_struct.sub(divisions_index);
divisions_per_quarter = sscanf(divisions_struct.sub(1).data,'%d');

% Find key information
key_index = find(strcmp({attributes_struct.sub.name},'key'));
if (isempty(key_index))
    fprintf(1,'No key information available...\n');
    info.error = -1;
    return;
end
key_struct = attributes_struct.sub(key_index);

fifths_struct = getelements(key_struct,'fifths');

% We really can't proceed without key information...
if (isempty(fifths_struct))
    fprintf(1,'No key information available...\n');    
    info.error = -1;
    return;
end
initial_fifths = sscanf(fifths_struct.sub(1).data,'%d');

% Find mode information (required in the MusicXML standard, but not
% critical for us, and sometimes missing)
mode_struct = getelements(key_struct,'mode');
if (isempty(mode_struct))
    fprintf(1,'Warning: mode information not available\n');
    initial_mode = UNKNOWN_MODE_TAG;
else
    initial_mode = mode_struct.sub(1).data;
end
                
[initial_key_index initial_key_name] = fifths_to_index(initial_fifths);

% In this case, 'fifths' still shows us the right number of sharps/flats...

% if (0==strcmp(mode,'major'))
%    fprintf(1,'\n\nError: I only know how to handle major keys...\n\n');
% end

% Key will be represented with C = 0, moving up in half-steps from there

% Find time sig information
time_index = find(strcmp({attributes_struct.sub.name},'time'));
time_struct = attributes_struct.sub(time_index);
beats_per_measure = sscanf(time_struct.sub(1).sub(1).data,'%d');
beat_unit = sscanf(time_struct.sub(2).sub(1).data,'%d');

quarters_per_measure = beats_per_measure / (beat_unit / 4);
divisions_per_measure = divisions_per_quarter * quarters_per_measure;

divisions_per_beat = divisions_per_measure / beats_per_measure;

if (beats_per_measure ~= round(beats_per_measure))
    fprintf(1,'Warning: non-integral number of beats %f per measure...\n', beats_per_measure);
end
    
% fprintf(1,'Initial key is %s %s\n',initial_key_name,mode);
% fprintf(1,'Divisions per measure is %d\n',divisions_per_measure);

info.key_name = {initial_key_name};
info.key_index = initial_key_index;
info.key_mode = {initial_mode};
info.beats_per_measure = beats_per_measure;
info.beat_unit = beat_unit;

% This tells us the offset into the song (in beats) where the key
% changes indicated in key_index, key_name, and key_mode happen

info.key_changes = [0];
info.meter_changes = [];
info.tempo_changes = [];

% This lists note indices that are really "silent" extensions of previous
% notes
info.silent_notes = [];

% This tells us at which beat each measure starts
info.measure_start = [];

n_notes = 0;
n_chords = 0;

% How many beats into the song are we?

% The current song position, in beats
song_position = 0;

% The current chord position, in beats
chord_song_position = 0;

% no ties yet
tie_prev = 0;
tie_next = 0;
previous_original_measure_number = 1;

% A few things we like to print exactly once as sanity-checks
printed_slash_warning = 0;
printed_meter_change_notice = 0;
printed_melisma_notice = 0;

% Remove all non-measure elements
allmeasures = measures;

% This is only meaningful for debugging, when we run parts of this function
% outside of a function context.
clear measures;
nmeasures = 0;
for(i=1:length(allmeasures))
    m = allmeasures(i);
    if (0==strcmp(lower(m.name),'measure'))
        continue;
    end
    nmeasures = nmeasures + 1;
    measures(nmeasures) = allmeasures(i);
end

%%

% We ignore all notes in "slash-style" measures
currently_in_slash_style = 0;
   
% Go through each measure, transposing notes and chords and building
% the output matrices
for(i=1:length(measures))
   
%%

    m = measures(i);

    % fprintf('Processing original measure number %d\n',m.original_measure_number);
    
    % Record the beat at which this measure starts
    info.measure_start = [info.measure_start song_position];
    
    % How far into the measure are we (in beats)?
    measure_position = 0;

    % Actual XML measure position (in beats).  This may be different than
    % "measure_position" if we have to "rewind" within a measure because of
    % a "backup" directive, usually used to reset the clock to specify chord 
    % timing after all the notes are done.
    xml_measure_position = 0;
    
    chords_in_measure = 0;
    chord_measure_position = 0;

    % Not a backup measure (yet)
    backup_measure = 0;
    
    if (~(isfield(m,'sub')))
        fprintf(1,'Warning: measure %d has no sub content\n',m.original_measure_number);
        continue;
    end
    
    if (isempty(m.sub))
        fprintf(1,'Warning: measure %d has no content\n',m.original_measure_number);
        continue;
    end
    
    subnames = {m.sub.name};
    
    % For every xml element in this measure...
    for(j=1:length(m.sub))

        % fprintf(1,'Processing element %s\n',m.sub(j).name);
        
        % Look for metadata on this measure
        if ((strcmp(subnames{j},'attributes')))
        
            % We're not interested in time/key changes in the first measure
            if (i~=1)
        
                % Look for a key change...
                k = getelements(m.sub(j),'key');
                if (~(isempty(k)))
                    fifths_struct = getelements(k,'fifths');
                    new_fifths = sscanf(fifths_struct.sub(1).data,'%d');
                    mode_struct = getelements(k,'mode');
                    
                    if (isempty(mode_struct))
                        fprintf(1,'Warning: mode information not available at key change...\n');
                        new_mode = UNKNOWN_MODE_TAG;
                    else
                        new_mode = mode_struct.sub(1).data;
                    end

                    [new_key_index new_key_name] = fifths_to_index(new_fifths);

                    % Make sure it's really a change
                    if (new_key_index ~= info.key_index(end))

                        old_key_index = info.key_index(end);
                        old_key_name = info.key_name{end};

                        info.key_index = [info.key_index new_key_index];
                        info.key_name = {info.key_name{:} new_key_name};
                        info.key_mode = {info.key_mode{:} new_mode};

                        % fprintf(1,'At measure %d (beat %d), changing from key %d (%s) to %d (%s)\n',...
                        %     i,song_position,old_key_index,old_key_name,new_key_index,new_key_name);

                        % Record the key-change event
                        info.key_changes = [info.key_changes song_position];
                    end
                end

                meter_changed = 0;

                % Look for a meter change...

                % First look for "divisions" changes
                div = getelements(m.sub(j),'divisions');
                if (~isempty(div))
                    new_div_per_quarter = sscanf(div.sub(1).data,'%d');

                    if (new_div_per_quarter ~= divisions_per_quarter)
                        divisions_per_quarter = new_div_per_quarter;
                        meter_changed = 1;
                    end
                end

                % Now look for "time signature" changes
                time = getelements(m.sub(j),'time');
                if (~isempty(time))
                    new_beats_per_measure = sscanf(time.sub(1).sub(1).data,'%d');
                    new_beat_unit = sscanf(time.sub(2).sub(1).data,'%d');

                    if ((new_beats_per_measure ~= beats_per_measure) || (new_beat_unit ~= beat_unit))
                        beats_per_measure = new_beats_per_measure;
                        beat_unit = new_beat_unit;
                        meter_changed = 1;
                    end
                end

                if (meter_changed)
                    % Just print meter-change notices once as a
                    % sanity-check...
                    if (printed_meter_change_notice == 0)
                        fprintf(1,'Meter change in measure %d to %d/%d time...\n',m.original_measure_number,beats_per_measure,beat_unit);
                        % printed_meter_change_notice = 1;
                    end
                    

                    % Update the necessary timing parameters.
                    quarters_per_measure = beats_per_measure / (beat_unit / 4);
                    divisions_per_measure = divisions_per_quarter * quarters_per_measure;
                    divisions_per_beat = divisions_per_measure / beats_per_measure;

                    if (beats_per_measure ~= round(beats_per_measure))
                        fprintf(1,'Warning: non-integral number of beats %f per measure...\n', beats_per_measure);
                    end
                    
                    changeIndex = size(info.meter_changes,1) + 1;
                    info.meter_changes(changeIndex,1) = song_position;
                    info.meter_changes(changeIndex,2) = beats_per_measure;
                    info.meter_changes(changeIndex,3) = beat_unit;
                end
                
            end % ...if this is the first measure
            
            % Now look for "measure style" changes; we're specifically
            % interested in "slash style" indicators, meaning that notes
            % aren't _really_ pitched notes, just rhythm indicators
            measurestyle_list = getelements(m.sub(j),'measure_style');
            if (~isempty(measurestyle_list))          
                % Sometimes there are multiple measure style changes in a
                % single measure's attribute list
                for(curmeasurestyle=1:length(measurestyle_list))
                    measurestyle = measurestyle_list(curmeasurestyle);
                    slash = getelements(measurestyle,'slash');
                    if (~isempty(slash))
                        type = slash.data.type;
                        if (1==strcmpi(type,'start'))
                            if (printed_slash_warning == 0)
                                printed_slash_warning = 1;
                                fprintf(1,'Song contains "slash notes", ignoring those notes...\n');
                            end
                            % fprintf(1,'Entering slash style at measure %d (originally %d)\n',i,m.original_measure_number);
                            currently_in_slash_style = 1;
                        elseif (1==strcmpi(type,'stop'))
                            % fprintf(1,'Exiting slash style at measure %d (originally %d)\n',i,m.original_measure_number);
                            currently_in_slash_style = 0;
                        else
                            fprintf(1,'Warning: unrecognized slash type delimiter %s\n',type);
                            currently_in_slash_style = 0;
                        end
                    end
                end
            end

        end % If this is an attribute tag...
        
        % If we've already seen a chord, we should only see chords and
        % forwards (time steps) from then on for the rest of the measure, since chords live at
        % the end of a measure...
        if (chords_in_measure ~= 0)
            if (strcmp(subnames{j},'harmony')==0 && strcmp(subnames{j},'forward')==0 && strcmp(subnames{j},'measure')==0)
               % fprintf(1,'Warning... I''ve already seen a harmony tag in measure %d, but now I''m seeing tag: [%s]\n',...
               %    i,subnames{j});
            end
        end
        
        % If this is a note...
        if (strcmp(subnames{j},'note'))
            
            % A flag we'll use to mark this note as "silent" if it's really
            % an unplayed extension (by tie) of a previous note
            silent = 0;
            
            % fprintf(1,'Processing new note...\n');
            
            n = m.sub(j);
            
            % Ignore 'chord notes'...
            c = getelements(n,'chord');            
            if (~(isempty(c)))
               % fprintf(1,'Warning: ignoring chord note in measure %d\n',i);
               continue;
            end
            
            % All notes should have duration...
            d = getelements(n,'duration');
            
            % Unfortunately, some don't... default to one division
            if (~isempty(d))
                % Convert this note duration from "divisions" to beats
                note_duration = sscanf(d.sub(1).data,'%d') / divisions_per_beat;
            else
                fprintf(1,'Warning: note in measure %d has no duration\n',i);
                note_duration = 0;
            end
            
            % Advance all of our clocks forward by this much time...
            note_start = song_position;
            note_end = song_position + note_duration;
            song_position = song_position + note_duration;
            measure_position = measure_position + note_duration;
            xml_measure_position = xml_measure_position + note_duration;
            
            % Notes that are just slashes aren't helpful...
            if (currently_in_slash_style)
                continue;
            end
                        
            % We're only interested in voice 1, which we presume is
            % generally the melody in the data files we're looking at.
            % Alternate voicings generally represent different verses, etc.            
            v = getelements(n,'voice');
            if (~(isempty(v)))
               voice = sscanf(v.sub(1).data,'%d');
               if (voice ~= 1)
                  % fprintf(1,'Warning: ignoring note in measure %d for voice %d\n',i,voice);
                  continue;
               end
            end
                        
            % Is this note already a tie (an extension of the previous note)?
            if (tie_next)
                tie_prev = 1;
            else
                tie_prev = 0;
            end
            tie_next = 0;
            
            % Look for tie element
            tie_struct = getelements(n,'tie');
            for tie=1:length(tie_struct)
                if (isfield(tie_struct(tie).data,'type'))
                    if (~tie_prev)
                        % check if the note should be tied to the previous
                        tie_prev = (~isempty(strfind(lower(tie_struct(tie).data.type),'stop')));                        
                    end
                    
                    % find out if the next note should be tied to this one
                    tie_next = (~isempty(strfind(lower(tie_struct(tie).data.type),'start')));                    
                end
            end                      

            % If this is a tied note across a repeat, don't treat it as a
            % tied note
            if (previous_original_measure_number > m.original_measure_number)
               tie_prev = 0;               
            end
            previous_original_measure_number = m.original_measure_number;
            
            % Check whether this is tied to the previous note
            if ((n_notes > 0) && (tie_prev))
                
                old_pitch_index = notes(n_notes,3);
                old_octave = notes(n_notes,4);
                
                [new_pitch_index, new_octave] = get_note_info(n);
                   
                % Don't let the tie state persist across this note...
                tie_prev = 0;                               
                
                if ( ...
                    (new_pitch_index >=0) && (new_octave >= 0) && ...
                    ((new_pitch_index ~= old_pitch_index) || (new_octave ~= old_octave)) ...
                    )
                   
                    % This looks like legitimate melisma; let's process this
                    % as a brand-new note.
                    if (printed_melisma_notice == 0)
                        printed_melisma_notice = 1;
                        % fprintf(1,'Apparent melisma at measure %d (original measure %d) (%d.%d --> %d.%d)\n',...
                          %  i,m.original_measure_number,old_octave,old_pitch_index,new_octave,new_pitch_index);
                    end
                     
                else
                    
                    % This is a 'garbage tie... but might still have
                    % lyrical implications, so we mark it as silent, 
                    % rather than throwing it out
                    silent = 1;
                    
                end                               
                
                % Extend the duration of the previous note to include this
                % one, if we're not marking it as a "silent" note
                if (silent == 0)
                    notes(n_notes,2) = note_end;
                end
                                
            end
            
            % What kind of note is this (pitch or rest)?
            
            p = getelements(n,'pitch');
            r = getelements(n,'rest');
            
            % If this is a pitched note...
            if (~(isempty(p)))

                % We're processing a new note; find the octave and scale
                % degree...
                n_notes = n_notes + 1;
                
                % Mark this as a silent note
                if (silent)
                    info.silent_notes = [info.silent_notes; n_notes];
                end
                
                % Get pitch and octave information for this note
                [pitch_index, octave] = get_note_info(n);
                
                % fprintf(1,'Processing note %d.%d.%d\n',m.original_measure_number,octave,pitch_index);
                
                % Store this note in the big output array of notes
                notes(n_notes,:) = [note_start,note_end,pitch_index,octave];
                                
            end % ...if this is a pitched note.
            
            % If this is a rest...
            if (~(isempty('r')))
                
                % Already updated song_position and measure_position; don't
                % need to do anything...
                
            end % ...if this is a rest.
        
            % Does this note have lyrics?
            lyricelements = getelements(n,'lyric');
            % fprintf(1,'Processing %d lyrics...\n',length(lyricelements));
                
            if (~(isempty(lyricelements)))
                                
                if (length(lyricelements) > 1)
                    % fprintf(1,'Warning: multiple lyrics for the same note at original measure %d\n',m.original_measure_number);                
                end
                
                % For all the lyric elements associated with this note
                for(lyricindex=1:length(lyricelements))
                                        
                    lyricstruct = lyricelements(lyricindex);

                    try

                        % Parse number and name information
                        if (isfield(lyricstruct.data,'number'))
                           lyric_number = sscanf(lyricstruct.data.number,'%d');                       
                        end
                    
                        % We don't do anything with this information right
                        % now... most songs don't have this.  It associates
                        % lyrics with chorus, verse, bridge, etc.
                        if (isfield(lyricstruct.data,'name'))
                           % fprintf(1,'Lyric attached to structural name: %s\n',lyricstruct.data.name); 
                        end

                        % Look for syllable type, which is required
                        syllablestruct = getelements(lyricstruct,'syllabic');
                        if (isempty(syllablestruct))
                            fprintf(1,'Warning: empty syllable struct at original measure %d\n',m.original_measure_number);
                            error('-1');
                        end

                        if(length(syllablestruct) > 1)
                            % fprintf(1,'Warning: multiple syllables for the same lyric at original measure %d\n',m.original_measure_number);                
                            syllablestruct = syllablestruct(1);                        
                        end

                        syllabletypestring = syllablestruct.sub(1).data;

                        if (1==strcmpi(syllabletypestring,'single'))
                            syllabletype = SYLLABLE_SINGLESYLLABLE;
                        elseif (1==strcmpi(syllabletypestring,'begin'))
                            syllabletype = SYLLABLE_WORDBEGIN;
                        elseif (1==strcmpi(syllabletypestring,'end'))
                            syllabletype = SYLLABLE_WORDEND;
                        elseif (1==strcmpi(syllabletypestring,'middle'))
                            syllabletype = SYLLABLE_WORDCONTINUATION;
                        % This one doesn't really exist, but is used
                        % sometimes
                        elseif (1==strcmpi(syllabletypestring,'continue'))
                            syllabletype = SYLLABLE_WORDCONTINUATION;
                        else
                            fprintf(1,'Warning: unknown syllable type %s at original measure %d\n',syllabletype,m.original_measure_number);
                            error('-1');
                        end

                        % Look for text, which is required
                        textstruct = getelements(lyricstruct,'text');
                        if (isempty(textstruct))
                            fprintf(1,'Warning: empty text struct at original measure %d\n',m.original_measure_number);
                            error('-1');
                        end

                        if(length(textstruct) > 1)
                            text = textstruct(1).sub(1).data;
                            for(textindex=2:length(textstruct))
                                text = [text ' ' textstruct(textindex).sub(1).data];
                            end                            
                            % fprintf(1,'Warning: multiple text structs for the same lyric (%s) at original measure %d\n',text,m.original_measure_number);                                            
                        else
                            text = textstruct.sub(1).data;
                        end

                        if (isempty(text))
                            fprintf(1,'Warning: empty text struct at original measure %d\n',m.original_measure_number);                
                        end

                        lyricstruct = struct;
                        lyricstruct.text = text;
                        lyricstruct.word_position = syllabletype;
                        lyricstruct.lyric_number = lyric_number;
                        lyricstruct.measure_number = m.original_measure_number;

                        % Associate this lyric with the current note
                        lyricstruct.note_index = n_notes;

                        % If the lyric number doesn't match the copy
                        % number, sometimes we want this lyric and
                        % sometimes we don't
                        if (lyric_number ~= m.copy_number)                 
                        
                            % If there are multiple lyrics here, we only want
                            % to keep ones that actually belong in this copy of the measure
                            if (length(lyricelements) > 1)
                                % fprintf(1,'Lyric number %d does not match copy number %d for lyric %s at measure %d\n', lyric_number, m.copy_number, text, m.original_measure_number);
                                continue;
                            end
                        
                            % Okay, there's only one lyric here.  Throw
                            % this lyric out if there are _some_ lyrics in this measure that _do_ match the 
                            % "lyric number" for this measure.
                            measure_lyric_numbers = get_measure_lyric_numbers(m);
                            
                            % If some notes in this measure _do_ match my
                            % copy number, skip this note
                            if (~(isempty(find(measure_lyric_numbers == lyric_number))))
                                continue;                                
                            end
                        end
                        
                        % fprintf(1,'Keeping lyric number %d for copy number %d for lyric %s at measure %d\n', lyric_number, m.copy_number, text, m.original_measure_number);
                                                
                        % Store this lyric in our big array               
                        lyricindex = length(lyrics)+1;
                        if (lyricindex == 1)
                            clear lyrics;
                        end
                        lyrics(lyricindex) = lyricstruct;

                        % fprintf(1,'Parsing lyric: %d\t%d\t%s (measure %d)\n',lyricindex,lyrics(lyricindex).word_position,lyrics(lyricindex).text, m.original_measure_number);
                        
                     catch me                    
                         
                         fprintf(1,'Ignoring lyric at original measure %d, error %s\n',m.original_measure_number, me.message);
                         
                    end
                    
                end % for each individual lyric associated with this note
                
            end % if there are lyrics
            
        end % if this is a note
                
        % The 'backup' tag backs up the current clock, and it's typically 
        % used to wind back to the beginning of the measure to insert the
        % chords.
        if (strcmp(subnames{j},'backup'))
            
            % Yes, this measure has a 'backup' tag in it
            backup_measure = 1;
            
            % Also do the right thing -- wind back xml measure position
            % 
            % At this point "measure_position" still identifies the
            % farthest forward we've come so far
            d = getelements(m.sub(j),'duration');
            duration = sscanf(d.sub(1).data,'%d') / divisions_per_beat;
            xml_measure_position = xml_measure_position - duration;
            
            % We should never be asked to roll back before the beginning
            % of the measure
            if (xml_measure_position < -EPSILON)
                fprintf(1,'Warning: measure position less than zero\n');
            end
        end
        
        % If this is a chord...
        if (strcmp(subnames{j},'harmony'))          
            
            % Use the position of the most recent note to estimate the
            % timing of this chord if the chord position is unclear
            if (~backup_measure)
                use_note_position = 1;
            else
                use_note_position = 0;
            end
            
            % If this is the first chord in the measure and it was
            % immediately preceded by one or more 'forward' tags (which is a typical
            % way of placing chords in time), parse those tags and move the chord along.
            k = j-1;
            while(chords_in_measure == 0 && k >= 1 && strcmp(subnames{k},'forward'))
                
                % Parse the duration (in beats)
                d = getelements(m.sub(k),'duration');
                duration = sscanf(d.sub(1).data,'%d') / divisions_per_beat;
                
                % Move our "chord clocks" along, for both the song and the
                % current measure
                chord_song_position = chord_song_position + duration;
                chord_measure_position = chord_measure_position + duration;
                % fprintf(1,'Mid-measure chord at measure %d (ofsetting by %f)\n',i,duration);
                k = k - 1;                
                
                % Don't use note position to estimate chord position
                use_note_position = 0;
            end
            
            % Also, the 'offset' tag is sometimes used to push a chord
            % forward.
            xml_offset = getelements(m.sub(j),'offset');
            if (~isempty(xml_offset))
                % use beats now
                %offset = sscanf(xml_offset.sub(1).data,'%d') / divisions_per_measure;
                offset = sscanf(xml_offset.sub(1).data,'%d') / divisions_per_beat;
            else
                offset = 0;
            end
            
            % Use the current note position for this chord.
            %if (use_note_position)
            %    chord_song_position = song_position + offset;
            %    chord_measure_position = measure_position + offset;
            %end
            
            chord_song_position = info.measure_start(end) + xml_measure_position + offset;
            chord_measure_position = xml_measure_position + offset;
            
            % Check that this chord's position is different than the
            % previous chord's position
            if (n_chords ~= 0)
               previous_chord_position = chords(end,1);
               if (chord_song_position <= previous_chord_position)
                  fprintf(1,'Warning: chords overlap in original measure %d\n',m.original_measure_number);
               end
            end
            
            n_chords = n_chords + 1;
            chords_in_measure = chords_in_measure + 1;
            
            % Process the chord type and scale degree
            h = m.sub(j);
            root_struct = getelements(h,'root');
            root_step_struct = getelements(root_struct,'root_step');            
            root_step_name = root_step_struct.sub(1).data;
            root_step_index = note_index_from_name(root_step_name);
            
            root_alter_struct = getelements(root_struct,'root_alter');
            if (~(isempty(root_alter_struct)))
                root_alter = sscanf(root_alter_struct.sub(1).data,'%d');
            else
                root_alter = 0;
            end
            
            root_step_index = root_step_index + root_alter;
            if (root_step_index < 0) root_step_index = root_step_index + 12; end;
            if (root_step_index > 12) root_step_index = root_step_index - 12; end;
                
            octave = DEFAULT_CHORD_OCTAVE;
            kind_struct = getelements(h,'kind');
            chord_name = kind_struct.sub(1).data;
            
            [chord_notes chord_offsets] = get_chord_notes(root_step_index,octave,chord_name);
            
            degree_struct = getelements(h,'degree');
            
            % For each degree modifier in this chord
            for deg=1:length(degree_struct)
                
                degree_value = -1;
                degree_alter = Inf;
                degree_type = 'unknown';
                    
                % For each field in this degree modifier
                for(sub_index=1:length(degree_struct(deg).sub))
                
                    % Ignore this field
                    if (isempty(degree_struct(deg).sub(sub_index).sub))
                        continue;
                    end
                    
                    % Is this telling me which degree to modify?
                    token_name = degree_struct(deg).sub(sub_index).name;
                    if (strcmpi(token_name,'degree_value'))
                        degree_value = sscanf(degree_struct(deg).sub(sub_index).sub(1).data,'%d');
                    elseif (strcmpi(token_name,'degree_alter'))
                        degree_alter = sscanf(degree_struct(deg).sub(sub_index).sub(1).data,'%d');
                    elseif (strcmpi(token_name,'degree_type'))
                        degree_type = degree_struct(deg).sub(sub_index).sub(1).data;
                    else
                        fprintf(1,'Unrecognized degree modification token %s at original measure %d\n',token_name,m.original_measure_number);
                    end
                end
                                
                % If we're being asked to alter an existing scale degree
                if (strcmpi(degree_type,'alter'))
                    if (degree_alter == Inf || degree_value == -1)
                        fprintf(1,'Warning: at original measure %d, I''m asked to alter an unspecified degree %d.%d...\n',...
                            m.original_measure_number, degree_value, degree_alter);
                    else
                        % fprintf(1,'At original measure %d, I''m processing an alteration of degree %d.%d to a %s chord...\n',m.original_measure_number, ...
                          %  degree_value, degree_alter, chord_name);
                        [chord_notes chord_offsets] = alter_chord_notes(chord_notes,chord_offsets,[degree_value degree_alter]);
                    end
                elseif (strcmpi(degree_type,'add'))
                    % 
                    % TODO: It would be nice to actually process these, if
                    % only to update the chord names that I store, in case
                    % later we go back and do some analysis on extended
                    % chords.
                    % fprintf(1,'Warning: at original measure %d, I''m ignoring an addition of degree %d.%d to a %s chord...\n',m.original_measure_number, ...
                      %  degree_value, degree_alter, chord_name);
                else
                    % fprintf(1,'Warning: unrecognized degree-processing directive %s (value %d, alter %d) at measure %d\n', ...
                      %  degree_type, degree_value, degree_alter, m.original_measure_number);
                end
            end
            
            triad = triad_from_chord_offsets(chord_offsets);
            
            if (triad == TRIAD_UNKNOWN)
                % fprintf(1,'Unknown triad from type %s at measure %d (after flattening)\n', chord_name, i);
            end
            
            chords(n_chords,:) = [chord_song_position,chord_song_position,root_step_index,octave,triad];
            chord_names{n_chords,1} = chord_name;
            
            % The previous chord should not end until this one begins
            if (n_chords > 1)
                chords(n_chords-1,2) = chord_song_position;
            end
                                   
        end % ...if this is a chord.
        
        % If this is a forward tag...
        if (strcmp(subnames{j},'forward'))

            % I only care about this if I've already seen a chord in this
            % measure
            if (chords_in_measure ~= 0)                

                % Parse the duration
                d = getelements(m.sub(j),'duration');
                % use beats now
                %duration = sscanf(d.sub(1).data,'%d') / divisions_per_measure;
                duration = sscanf(d.sub(1).data,'%d') / divisions_per_beat;
                
                % Set the end-time for the previous chord and update the current
                % chord position

                chord_additional_duration = duration;
                chord_start = chords(n_chords,1);
                chord_previous_end = chords(n_chords,2);
                chord_end = chord_previous_end + chord_additional_duration;
                chord_song_position = chord_song_position + chord_additional_duration;
                chord_measure_position = chord_measure_position + chord_additional_duration;            
                chords(n_chords,2) = chord_end;
                
            end
            
            % Also use this to wind forward the xml measure position
            d = getelements(m.sub(j),'duration');
            duration = sscanf(d.sub(1).data,'%d') / divisions_per_beat;
            
            xml_measure_position = xml_measure_position + duration;
                        
        end ...if this is a forward tag.
                    
    end % for each element in this measure

    % If this measure wasn't just about exactly 1 measure long...
    if ((abs(beats_per_measure-xml_measure_position)) > EPSILON)
        
        if (i==1)
            
            % This is just a pickup measure...
            measure_position = 1;
            
            % Move everything to the end of the measure.
            offset = beats_per_measure - xml_measure_position;
            notes(:,1:2) = notes(:,1:2) + offset;
            chords(:,1:2) = chords(:,1:2) + offset;
            
            xml_measure_position = beats_per_measure;
            
        elseif (i == length(measures))
            
            % This is just a finishing measure... 
            measure_position = 1;
            
            xml_measure_position = beats_per_measure;
           
        elseif ((abs(0-xml_measure_position)) < EPSILON)
            
            % This measure probably has other voices...
            song_position = song_position + beats_per_measure;
            measure_position = 1;
            
            xml_measure_position = beats_per_measure;
            
        else
            
            fprintf(1,'Warning: measure %d added up to %f beats...\n',i,xml_measure_position);
            
            % Some measures just seem to have notes missing...
            if (xml_measure_position < beats_per_measure)
                offset = beats_per_measure-xml_measure_position;
                song_position = song_position + offset;
                
                xml_measure_position = xml_measure_position + offset;
                
            % Some measures just seem to have extra duration...
            elseif (xml_measure_position > beats_per_measure)
                
                % This measure needs to be shortened.
                measure_end = info.measure_start(end) + beats_per_measure;
                xml_measure_position = beats_per_measure;
                
                % Shorten any notes or chords that would go too far.
                notes(:,1:2) = min(notes(:,1:2),measure_end);
                chords(:,1:2) = min(chords(:,1:2),measure_end);
            end
            
        end
        
    else
        % fprintf(1,'Measure %d looks good...\n',i);
    end

    % Do the same sanity-checking on chord_measure_position...
    
    % Many measures just don't have chords...
    if (chords_in_measure == 0)
        
        % This means the previous measure's last chord is still alive...
        chord_song_position = chord_song_position + beats_per_measure;
        
        if (n_chords > 0)
           chords(end,2) = chords(end,2)+beats_per_measure;
        end
        
    % If this measure (for chords) wasn't just about exactly 1 measure long...
    else
        
        if (abs(1-chord_measure_position) > EPSILON)
        
            if (i==1)
               % This is just a pickup measure...
            elseif (i == length(measures))
                % This is just a finishing measure...
            else
                % not worth complaining about
                if (chord_measure_position > EPSILON)
                    %fprintf(1,'\nWarning: chords in measure %d added up to %f measures...\n\n',...
                        %i,chord_measure_position);
                else
                    % Sometimes there will be no chord, and that's not 
                end

            end
            
            offset = beats_per_measure-chord_measure_position;
            chord_song_position = chord_song_position + offset;

        end
        
    end
    
    % This seems necessary.
    song_position = info.measure_start(end) + xml_measure_position;
    
%%

end % for every measure

% the last chord should last until the song ends
if (n_chords > 0)
    chords(n_chords,2) = max(chords(n_chords,2),song_position);
end

if (abs(chord_song_position - song_position) >= 1)
    % not worth complaining about
    %fprintf(1,'\nWarning: chord song position is %f; song_position is %f\n\n',...
        %chord_song_position,song_position);
end