% Top-lvel script for processing one database (one directory)
% full of MusicXML files.  
%
% Writes a single structure (all_songs) to ../output/musicxml.mat
%
% Also writes four text files for each song to ../output/[dir]*.txt, 
% where [dir] is a datestamped folder name.
%
% See ../readme.txt for information about the formats of all of these
% files.

% This defines the directory where all of your musicxml files are.  Be sure
% to set this appropriately.
if (~(exist('DATAPATH','var')))
    DATAPATH = '../data/test';
end

% Set up global constants used throughout all these scripts.
define_music_globals;

% These two variables are for debugging; I change this when I want to run this whole script for
% a subset of the data, or when I want to re-start the script if it dies somewhere in the
% middle.
%
% If this is -1, we'll process all available data.
FILES_TO_PROCESS = -1;
STARTING_FILE_INDEX = -1;

% Keep a list of files we failed to parse
non_leadsheet_filenames = {};

FLAG_PROBABLE_DUPLICATES = 1;
REMOVE_PROBABLE_DUPLICATES = 0;

% Should we throw out songs that have no chords?
DISCARD_CHORDLESS_SONGS = 1;

% Set up the output file, where we'll write the output structures
if (~exist('MATLAB_OUTPUT_FILE'))
    MATLAB_OUTPUT_FILE= '../output/musicxml.mat';
end

% Set up regular expressions used to define which files we care about
%
% Generally this will be *.xml
if (~exist('VALID_XML_FILENAME_REGEXP','var'))
    VALID_XML_FILENAME_REGEXP = 'xml';
end

% Should we be trying to find files within lead sheets that aren't named
% like lead sheets and might have multiple parts?
PULL_LEAD_SHEETS_FROM_MULTIPART_FILES = 1;

% If we are trying to pull lead sheets out of multi-part files, this is 
% the hard-coded part name we'll be looking for.  This is not used for
% parsing the Wikifonia collection.
if (~exist('VALID_XML_PARTNAME_REGEXP','var'))
    VALID_XML_PARTNAME_REGEXP = 'leadsheet';
end

% Set up relevant code paths
XML_TOOLS_PATH = '..\matlab_xml_tools\xml_tools';
addpath(XML_TOOLS_PATH);

MIDI_TOOLBOX_PATH = '..\matlab_midi_tools\midi_toolbox';
addpath(MIDI_TOOLBOX_PATH);

MIDI_WRITER_PATH = '..\mf2t';
addpath(MIDI_WRITER_PATH);

addpath(pwd);

% Create the structure array where we'll store all the final data
all_songs = struct;

% Grab all the files in our data directory
files = dir(DATAPATH);

% This is an index into our output array; it represents the number of files
% we've _actually_ processed
fileindex = 1;

% Set up midi output...
%
% Actually getting this to work is sort of a pain... I just write out midi
% files and play them in the shell now.
%
% midiplayer = setmidiplayer('C:\Program Files\Windows Media Player\wmplayer.exe');

% For every file
LAST_FILE_INDEX = length(files);

if (STARTING_FILE_INDEX < 1) STARTING_FILE_INDEX = 1; end;
    
for(i=STARTING_FILE_INDEX:LAST_FILE_INDEX)

    % Does the name of this file tell us right away that we should be using
    % it?
    valid_name = 1;
    
    if (FILES_TO_PROCESS ~= -1)
        if (fileindex > FILES_TO_PROCESS)
            fprintf(1,'Processed all requested files...\n');
            break;
        end
    end
    
    % If this filename isn't interesting to us, skip it...
    name = files(i).name;
    
    % Filenames that aren't .xml are not valid
    if (length(name) < 4) continue; end;
    
    dots = strfind(name,'.');
    if (isempty(dots)) continue; end;
    lastdot = dots(end);
    extension = name(lastdot:end);
    if (0==strcmpi(extension,'.xml'))
        fprintf(1,'%s is not an xml file; skipping...\n',name);
        continue;
    end
    
    [start_indices end_indices extents match tokens names] = ...
        regexp(name,VALID_XML_FILENAME_REGEXP,'ignorecase');

    if (length(start_indices)==0)
        % fprintf(1,'Not interested in: %s\n',name);
        % continue;
        
        % This file doesn't look like a lead sheet, but that doesn't mean
        % we can't use it... maybe there's an individual part that's a lead
        % sheet.
        valid_name = 0;
        
        if (PULL_LEAD_SHEETS_FROM_MULTIPART_FILES == 0)
            % Keep a list of files we failed to parse
            non_leadsheet_filenames{length(non_leadsheet_filenames)+1} = files(i).name;
            continue;
        end
    end

    % Processing a single xml file

    % This is redundant but convenient for debugging...    
    name = files(i).name;
    
    fullpath = sprintf('%s/%s',DATAPATH,name);

    % Determine if file is UTF-8 or UTF-16
    fid = fopen(fullpath);
    
    if (fid == -1)
        continue;
    end
    
    fprintf(1,'\nProcessing file: %s (file index %d, will be stored at index %d)\n',name,i,fileindex);
    
    ftest = fread(fid,4,'uint8');
    fclose(fid);
    
    ENCODING_BITS = 8;
    
    % This is probably a hack, but it seems to work.
    if ((ftest(1)==255) && (ftest(2)==254))
        ENCODING_BITS = 16;
    end
    
    % fprintf('Reading with %d-bit encoding\n',ENCODING_BITS);
    
    % Read the root element from the file (that should enclose the whole
    % file)
    fid=fopen(fullpath);
    if (ENCODING_BITS == 16)
        % Read out the 16-bit header
        fhead = fread(fid,1,'uint16');
        filetext = char(fread(fid,[1 inf],'uint16'));
    elseif(ENCODING_BITS == 8)
        filetext = char(fread(fid,[1 inf],'uint8'));
    else
        fprintf(1,'Unknown encoding size...\n');
    end
    fclose(fid);
            
    % Remote hyphenated element names
    % f = regexprep(f,'<([^->]{1,20})-([^->\W]{1,20})','<$1$2');
    %
    % Remote hyphenated attribute names
    % f = regexprep(f,'(\w+)-(\w+)=','$1$2=');
    % xml_data = xml_parseany(f);

    % Using the Matlab XML tools
    xml_data = xmlstruct(filetext,'sub');

    % Get the title, if it exists...
    %
    % Note that all hyphens in field names were converted to underscores
    % by the xml parser, so these differ a little from the musicxml
    % standard.
    scorestruct = getelements(xml_data,'score_partwise');
    titlestruct = getelements(scorestruct,'movement_title');
    if (~isempty(titlestruct))
        title = titlestruct.sub(1).data;
    else
        title = name;
    end
    
    % If we haven't confirmed that this is a lead sheet, we should check 
    % for an individual part that's a lead sheet
    part_id_to_extract = '';
    
    % I was thinking, at some point, of merging voice and chords tracks in
    % this code, but decided against it.  I'm still extracting the part
    % id's, but if I don't see a "lead sheet" track, I bail, even if I find
    % voice and chords tracks.
    voice_partid = '';
    chords_partid = '';
    part_ids_to_extract = {};
    
    if (valid_name == 0) 
        
        partliststruct = getelements(scorestruct, 'part_list');
        if (~isempty(partliststruct))
            if (length(partliststruct) > 1)
                fprintf(1,'Warning: multiple part lists...\n');
                partliststruct = partliststruct(1);
            end

            % Enumerate the parts...
            parts = getelements(partliststruct, 'score_part');
            for(part_index=1:length(parts))
                part = parts(part_index);
                partdata = part.data;
                if (isfield(partdata, 'id') == 0)
                    fprintf(1,'Warning: part without part ID\n');
                    continue;
                end
                partid = getfield(partdata, 'id');
                
                % Now go find the name of this part...
                partnamestruct = getelements(part, 'part_name');
                if (~isempty(partnamestruct))
                    if (length(partnamestruct) > 1)
                        fprintf(1,'Warning: multiple part names...\n');
                        partnamestruct = partnamestruct(1);
                    end
                    partname = partnamestruct.sub(1).data;
                    
                    % Is this a matching name?
                    [start_indices end_indices extents match tokens names] = ...
                        regexp(partname,VALID_XML_PARTNAME_REGEXP,'ignorecase');

                    if (length(start_indices)~=0)
                        fprintf('Reading part %s (id %s)\n',partname,partid);
                        part_id_to_extract = partid;
                        break;
                    end
                    
                    % Look for "voice" and "chords" parts, which are
                    % sometimes separate
                    if (strcmpi(partname,'voice')==1)
                        voice_partid = partid;
                    elseif (strcmpi(partname,'chords')==1)
                        chords_partid = partid;                       
                    end
    
                end
            end
        end
    end
    
    % If this doesn't look at all like a lead sheet, skip it...
    if ((valid_name == 0) && (length(part_id_to_extract) == 0))
        
        % One more possibility; if there are separate voice and chords
        % parts, we can deal with that...
        %
        % Actually, I bailed on this for now.  I'll just manually create
        % lead sheets for songs that aren't organized in a useful way.
        
        % if (length(voice_partid) ~= 0 && length(chords_partid) ~= 0)
        %     fprintf(1,'Trying to parse separate voice and chords parts...\n');
        %     part_ids_to_extract{1} = voice_partid;
        %     part_ids_to_extract{2} = chords_partid;
        % else
            fprintf(1,'This doesn''t look like a lead sheet, skipping it...');
            % Keep a list of files we failed to parse
            non_leadsheet_filenames{length(non_leadsheet_filenames)+1} = files(i).name;
            continue;
        % end
    end
    
    % fprintf(1,'Reading song: %s\n',title);

    % This is all the children of the main <part> tag in the score
    measures = measures_from_xml(xml_data, part_id_to_extract);
    
    % Tempo usually appears as an attribute on a "sound" tag, so we pull out 
    % the sound tag to find tempo.
    soundinfo = getelements(measures(1),'sound');

    tempo_bpm = 0;
    
    % A debugging flag to tell me how we found the tempo
    tempo_method = -1;

    % Get the tempo    
    if (~isempty(soundinfo))
        
        tempo_bpm = sscanf(soundinfo(1).data.tempo,'%d');
        tempo_method = 0;
        
    % If there's no <sound tempo="x"> tag, tempo can appear as a
    % "per_minute" attribute in a <direction> element
    else
        
        % Sound info isn't available... look for the metronome beat in the first measure...
        directions = getelements(measures(1),'direction');
        for(j=1:length(directions))
            direction = directions(j);
            direction_type_struct_list = getelements(direction,'direction_type');
            
            % Some songs have multiple direction-type elements
            for(k=1:length(direction_type_struct_list))
                direction_type_struct = direction_type_struct_list(k);
                if (~(isempty(direction_type_struct)))
                    metronome_struct = getelements(direction_type_struct,'metronome');
                    if (~(isempty(metronome_struct)))
                        
                        per_minute_struct = getelements(metronome_struct,'per_minute');
                        if (~(isempty(per_minute_struct)))
                            
                            % Okay, we found the tempo...
                            tempo_bpm = sscanf(per_minute_struct.sub(1).data,'%d');
                            tempo_method = 1;
                            break;
                            
                        end
                        
                    % Sometimes tempo appears in a <sound> tag within the direction
                    % tag...
                    else
                        sound_info_struct = getelements(direction,'sound');
                        if (~(isempty(sound_info_struct)))
                            if (isfield(sound_info_struct,'tempo'))
                                
                               % Okay, we found the tempo...
                               tempo_bpm = sscanf(sound_info_struct(1).data.tempo,'%d'); 
                               tempo_method = 2;
                               break;
                               
                            else
                               % That was my last resort for finding tempo...                               
                            end
                        end
                    end        
                    
                end
            end % for every <direction-type> element
        end % ...for every <direction> element
    end % ...finding the tempo

    % Choose a default tempo if we couldn't find a tempo
    if (tempo_bpm == 0)
        fprintf(1,'Warning: could not find tempo information...\n');
        tempo_bpm = 100;
    else
        fprintf(1,'Found tempo %d (method %d)\n',tempo_bpm,tempo_method);
    end
    
    % Build a note matrix; this call does all the hard work of parsing 
    % the data tree representing each measure
    [raw_notes, raw_chords, raw_chord_names, info, lyrics] = get_notes_and_chords(measures);
    
    % If this song didn't parse properly, just skip it
    if (info.error < 0)
        fprintf(1,'Error %d, skpping this song...\n',info.error);
        non_leadsheet_filenames{length(non_leadsheet_filenames)+1} = files(i).name;
        continue;
    end
    
    % Some songs aren't really lead sheets (they don't have chords; no
    % point in keeping them around)
    if (DISCARD_CHORDLESS_SONGS && (size(raw_chords,1) == 0))
        fprintf(1,'No chords; not including this song in the database...\n');
        non_leadsheet_filenames{length(non_leadsheet_filenames)+1} = files(i).name;
        continue;
    end
        
    % Grab some metadata that we want to put at the highest level in our
    % struct array
    input_key = info.key_index;
    output_key = 0;
    key_change_indices = info.key_changes;
        
    % Transpose everything to C (making a copy)
    [transposed_notes, transposed_chords, transposed_chord_names] = ...
        transpose_notes_and_chords(raw_notes, raw_chords, raw_chord_names, ...
        input_key, output_key, key_change_indices);

    % Convert everything to a playable nmat (making a copy)
    [raw_notes_nmat,raw_chords_nmat,raw_merged_nmat] = ...
        notes_and_chords_to_nmat(raw_notes,raw_chords,raw_chord_names,tempo_bpm);
    
    % Convert the transposed data to a playable nmat (making a copy)
    [transposed_chords_nmat,transposed_chords_nmat,transposed_merged_nmat] = ...
        notes_and_chords_to_nmat(transposed_notes,transposed_chords,transposed_chord_names,tempo_bpm);

    % Store everything in our output array
    all_songs(fileindex).info = info;
    all_songs(fileindex).raw_notes = raw_notes;
    all_songs(fileindex).raw_chords = raw_chords;
    all_songs(fileindex).raw_chord_names = raw_chord_names;
    all_songs(fileindex).transposed_notes = transposed_notes;
    all_songs(fileindex).transposed_chords = transposed_chords;
    all_songs(fileindex).transposed_chord_names = transposed_chord_names;
    all_songs(fileindex).raw_merged_nmat = raw_merged_nmat;
    all_songs(fileindex).transposed_merged_nmat = transposed_merged_nmat;
    all_songs(fileindex).fileindex = i;
    all_songs(fileindex).index = fileindex;
    all_songs(fileindex).filename = name;
    all_songs(fileindex).title = title;
    all_songs(fileindex).tempo_bpm = tempo_bpm;
    all_songs(fileindex).raw_lyrics = lyrics;
    all_songs(fileindex).lyrics = fix_syllables(lyrics);
    all_songs(fileindex).probable_duplicate = 0;
    
    % Useful sanity checks...
    if (size(raw_notes,1) < 25)
        fprintf(1,'Warning: only %d notes...\n',size(raw_notes,1));
    end
    
	if (size(raw_chords,1) < 10)
        fprintf(1,'Warning: this song has only %d chords...\n',size(raw_chords,1));
    end

    % To create a midi file, you would now run:
    % my_writemidi(raw_merged_nmat, 'tmp.mid', 240, tempo_bpm, info.beats_per_measure, info.beat_unit);
    
    % Increment the number of files we've stored
    fileindex = fileindex + 1;
    
end

% This script will flag and/or remove duplicates from all_songs, according
% to the (global) FLAG_PROBABLE_DUPLICATES and REMOVE_PROBABLE_DUPLICATES
% variables.
flag_or_remove_duplicate_songs;

% Save the output as a matlab file
save(MATLAB_OUTPUT_FILE,'all_songs');

% Write the text versions of all our data, into the output directory
pushd = pwd;
cd('../output');
write_text_data;
cd(pushd);
