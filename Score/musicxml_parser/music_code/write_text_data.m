% write_text_data.m
%
% This script creates the directory 'songdata.[datestamp]', and writes 
% four text files for every available song: a lyrics file, a notes file, 
% a chords file, and a measure-boundaries file, named as follows:
%
% nnn.lyrics.txt
% nnn.chords.txt
% nnn.notes.txt
% nnn.measures.txt
%
% All three files contain #-delimited comments at the top of the file
% indicating the title of the song and possibly other metadata.
% 
% The body of each file is a tab-delimited matrix, with fields in each row
% as follows.
%
%%%
% For the notes file:
%%%
%
% Each row defines one note, according to:
%
% [start] [end] [pitch_class] [octave]
% 
%   start: the starting time for this note, in beats
%   end: the ending time for this note, in beats
%   pitch_class: the pitch class of this note, from 0 (C) --> 11 (B)
%   octave: the octave in which this note should be played, relative to
%     middle C
%
%%%
% For the chords file:
%%%
%
% Each row defines one chord, according to:
%
% [start] [end] [root] [octave] [triad] [name]
% 
%   start: the starting time for this chord, in beats
%   end: the ending time for this chord, in beats
%   root: the root note of this chord, from 0 (C) --> 11 (B)
%   octave: the octave in which this chord should be played (not really
%     meaningful) triad: the triad assigned to this chord from its type; 
%     see the list of triads below
%   name: the name of this chord, such as 'major' or 'suspended-fourth'
%
% Available triads:
%
% TRIAD_UNKNOWN = -1;
% TRIAD_MAJOR = 0;
% TRIAD_MINOR = 1;
% TRIAD_DIMINISHED = 2;
% TRIAD_AUGMENTED = 3;
% TRIAD_SUSPENDED = 4;
%
%%%
% For the lyrics file: 
%%%
%
% Each row defines one syllable, according to:
%
% [note_index] [word_position] [lyric_number] [text] 
%
% note_index: an index into the 'notes' matrix for this song, indicating
%   the note to which this syllabel correspods
% word_position: an indicator of where this syllable falls in a word; see
%   the SYLLABLE* enumeration below
% lyric_number: If there are multiple lyrics for this note (probably
%   multiple verses), which one is this?
% text: the text corresponding to this syllabel
%
% SYLLABLE_SINGLESYLLABLE = 0;
% SYLLABLE_WORDBEGIN = 1;
% SYLLABLE_WORDCONTINUATION = 2;
% SYLLABLE_WORDEND = 3;
%
%%%
% For the measures file:
%%%
%
% The body of each file is a tab-delimited matrix, with fields in each row
% as follows, each row representing the start of a new measure:
% 
% [beat] [time sig numerator] [time sig denominator]
%

% Create the datestamp
t = clock;
datestamp = sprintf('%02d.%02d.%02d.%02d.%02d.%02d',...
    t(1),t(2),t(3),t(4),t(5),round(t(6)));

% Create the output directory
dirname = sprintf('songdata.%s',datestamp);

fprintf(1,'Writing data to %s\n',dirname);

mkdir(dirname);

% For each song
nsongs = length(all_songs);

for(cursongindex=1:nsongs)

    cursong = all_songs(cursongindex);
    
    filename = sprintf('%s\\%03d.notes.txt',dirname,cursongindex);
    f = fopen(filename,'w');
    fprintf(f,'#\tTitle\t%s\n',cursong.title);
    fprintf(f,'#\tSource Filename\t%s\n',cursong.filename);
        
    % Write out the notes file
    notes = cursong.transposed_notes;
    n_notes = size(notes,1);
    
    for(i=1:n_notes)
        fprintf(f,'%g\t%g\t%d\t%d\n',...
            notes(i,1),notes(i,2),notes(i,3),notes(i,4));
    end
    
    fclose(f);
    
    % Write out the chords file
    filename = sprintf('%s\\%03d.chords.txt',dirname,cursongindex);
    f = fopen(filename,'w');
    fprintf(f,'#\tTitle\t%s\n',cursong.title);
    fprintf(f,'#\tSource Filename\t%s\n',cursong.filename);
    
    chord_names = cursong.transposed_chord_names;
    chords = cursong.transposed_chords;    
    n_chords = size(chords,1);
    
    if (length(chord_names) ~= n_chords)
        error('Song %d: non-matching chord arrays\n',cursongindex);
    end
    
    for(i=1:n_chords)
        fprintf(f,'%g\t%g\t%d\t%d\t%d\t%s\n',...
            chords(i,1),chords(i,2),chords(i,3),chords(i,4),chords(i,5), ...
            chord_names{i});
    end
    
    fclose(f);
    
    % Write out the lyrics file
    filename = sprintf('%s\\%03d.lyrics.txt',dirname,cursongindex);
    f = fopen(filename,'w');
    fprintf(f,'#\tTitle\t%s\n',cursong.title);
    fprintf(f,'#\tSource Filename\t%s\n',cursong.filename);
    
    lyrics = cursong.lyrics;
    
    if (~isempty(lyrics))
        n_lyrics = length(lyrics);

        max_lyric_index = max(cell2mat({lyrics.note_index}));
        if ((max_lyric_index) > n_notes)
            error('Song %d: illegal lyric index\n',cursongindex);
        end

        for(i=1:n_lyrics)
            fprintf(f,'%d\t%d\t%d\t%s\n',...
                lyrics(i).note_index, lyrics(i).word_position,...
                lyrics(i).lyric_number, lyrics(i).text);
        end
    end
    
    fclose(f);
    
    % Write out the measures file
    filename = sprintf('%s\\%03d.measures.txt',dirname,cursongindex);
    f = fopen(filename,'w');
    fprintf(f,'#\tTitle\t%s\n',cursong.title);
    fprintf(f,'#\tSource Filename\t%s\n',cursong.filename);
        
    measures = cursong.info.measure_start;
    n_measures = size(measures,2);
    
    % Record initial time signature
    numerator = cursong.info.beats_per_measure;
    denominator = cursong.info.beat_unit;
    timesig_index = 1;
    meter_changes = cursong.info.meter_changes;
    
    % For each measure in the song
    for i=1:n_measures 
        
        cur_beat = measures(i);
        
        % update time sig.
        if (timesig_index <= size(meter_changes, 1))
            if (meter_changes(timesig_index,1) == cur_beat)
                numerator = meter_changes(timesig_index,2);
                denominator = meter_changes(timesig_index,3);
                timesig_index = timesig_index + 1;
            end
        end
        
        fprintf(f,'%d\t%d\t%d\n',...
            cur_beat, numerator, denominator);
    end
    
    fclose(f);
    
end
