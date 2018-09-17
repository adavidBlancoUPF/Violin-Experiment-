function print_song_lyrics(lyrics, mark_secondary_lyrics, print_note_numbers)
%
% function print_song_lyrics(lyrics)
%
% Debugging method to sanity-check lyric structures, and to show how these
% structures should be used.
%
% Constants from define_music_globals.m:
%
% SYLLABLE_SINGLESYLLABLE = 0;
% SYLLABLE_WORDBEGIN = 1;
% SYLLABLE_WORDCONTINUATION = 2;
% SYLLABLE_WORDEND = 3;

define_music_globals;
CHARACTERS_PER_LINE = 40;

if (nargin < 2)
    mark_secondary_lyrics = 0;
end

if (nargin < 3)
    print_note_numbers = 0;
end

% SYLLABLE_SINGLESYLLABLE = 0;
% SYLLABLE_WORDBEGIN = 1;
% SYLLABLE_WORDCONTINUATION = 2;
% SYLLABLE_WORDEND = 3;

if (isfield(lyrics,'lyrics'))
    lyrics = lyrics.lyrics;
end

nchars = 0;
for(i=1:length(lyrics))
    
    lyric = lyrics(i);
        
    % Some debugging notation for secondary lyric lines
    if (mark_secondary_lyrics && lyric.lyric_number ~= 1) 
        fprintf(1,'*');
    end
    
    % Print the text for this lyric
    text = lyric.text;
    
    % fprintf(1,text);
    
    lyric_number_string = '';
    if (print_note_numbers)
        lyric_number_string = sprintf('(%d,%d)',lyric.measure_number,lyric.note_index);
    end
    
    % Print spaces after whole words
    if (lyric.word_position == SYLLABLE_SINGLESYLLABLE)
        fprintf(1,' |%s%s| ',lyric_number_string,text);
    elseif (lyric.word_position == SYLLABLE_WORDEND)
        fprintf(1,'%s%s| ',lyric_number_string,text);
    elseif (lyric.word_position == SYLLABLE_WORDCONTINUATION)
        fprintf(1,'%s%s-',lyric_number_string,text);
    elseif (lyric.word_position == SYLLABLE_WORDBEGIN)
        fprintf(1,' |%s%s-',lyric_number_string,text);
    end
    
    % Print line breaks when we've printed a lot of characters or when the
    % current lyric number changes
    new_lyric_number = 0;
    if ((i > 1) && (lyric.lyric_number ~= lyrics(i-1).lyric_number))
        new_lyric_number = 1;
    end
    if (nchars >= CHARACTERS_PER_LINE || new_lyric_number)
        fprintf(1,'\n');
        nchars = 0;
    end

    nchars = nchars + length(text) + length(lyric_number_string);
        
end

fprintf(1,'\n');
