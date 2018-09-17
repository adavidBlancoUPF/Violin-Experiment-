function lyrics = fix_syllables(lyrics, print_errors)
%
% function lyrics = fix_syllables(lyrics)
%
% Goes through the list of lyric structs in 'lyrics' and looks for any 
% cases where "begin" syllables occur consecutively, changing the first to
% a "single" syllable.

define_music_globals;

if (nargin < 2)
    print_errors = 0;
end

for(i=1:length(lyrics))       
    
    if (print_errors)
        fprintf(1,'%d\t%d\t%d\t\t%s\t%s\n',i,lyrics(i).note_index,lyrics(i).word_position,word_position_names{lyrics(i).word_position+1},lyrics(i).text);
    end

    % Handle the beginning of the song specially
    if (i==1)
        
        % An end at the beginning of a song is a problem; make it a single
        if (i == 1 && lyrics(i).word_position == SYLLABLE_WORDEND)
            if (print_errors)
                fprintf(1,'1) Changing lyric %d (*%s* --> %s) (measure %d) to a single-syllable word\n',...
                    i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;

        % A continue at the beginning of a song is a problem; make it a
        % begin
        elseif (i == 1 && lyrics(i).word_position == SYLLABLE_WORDCONTINUATION)
            if (print_errors)
                fprintf(1,'2) Changing lyric %d (*%s* --> %s) (measure %d) to a begin\n',...
                    i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_WORDBEGIN;
            
        end
        
    % Handle the end of the song specially
    elseif(i==length(lyrics))
        
        % A continue at the end of a song is a problem; make it an end or a
        % single, depending on the preceding lyric
        if (i == length(lyrics) && lyrics(i).word_position == SYLLABLE_WORDCONTINUATION)
            if (print_errors)
                fprintf(1,'3) Changing lyric %d (*%s*) (measure %d) to an end\n',...
                    i,lyrics(i).text,lyrics(i).measure_number);
            end
            if (lyrics(i-1).word_position == SYLLABLE_WORDBEGIN || lyrics(i-1).word_position == SYLLABLE_WORDCONTINUATION)
                lyrics(i).word_position = SYLLABLE_WORDEND;
            else
                lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;
            end
        
        % A begin at the end of a song is a problem; make it a single
        elseif (i == length(lyrics) && lyrics(i).word_position == SYLLABLE_WORDBEGIN)
            if (print_errors)
                fprintf(1,'4) Changing lyric %d (*%s*) (measure %d) to a single-syllable word\n',...
                    i,lyrics(i).text,lyrics(i).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;        
            
        % An end at the end of a song not preceded by a begin or continue is a problem; make it a single
        elseif (i == length(lyrics) && lyrics(i).word_position == SYLLABLE_WORDEND && ...
            lyrics(i-1).word_position ~= SYLLABLE_WORDBEGIN && lyrics(i-1).word_position ~= SYLLABLE_WORDCONTINUATION)
            if (print_errors)
                fprintf(1,'5) Changing lyric %d (*%s*) (measure %d) to a single-syllable word\n',...
                    i,lyrics(i).text,lyrics(i).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;        
        end
    
    else

        % Any word ending in "-" and followed by an end or continue should
        % be made a begin or continue, depending on the previous syllable
        if ( ...
             (length(lyrics(i).text) > 0) && ... 
             (lyrics(i).text(length(lyrics(i).text))=='-') && ...
             (lyrics(i+1).word_position == SYLLABLE_WORDEND || lyrics(i+1).word_position == SYLLABLE_WORDCONTINUATION) ...
           )
        
            % If preceded by a begin, make it a continue
            if (lyrics(i-1).word_position == SYLLABLE_WORDBEGIN)
                if (print_errors)
                    fprintf(1,'6) Changing lyric %d (%s --> *%s*) (measure %d) to a continuation\n',...
                        i,lyrics(i-1).text,lyrics(i).text, lyrics(i-1).measure_number);
                end
                lyrics(i).word_position = SYLLABLE_WORDCONTINUATION;
            % Otherwise a begin
            else
                if (print_errors)
                    fprintf(1,'7) Changing lyric %d (%s --> *%s*) (measure %d) to a begin\n',...
                        i,lyrics(i-1).text,lyrics(i).text, lyrics(i-1).measure_number);
                end
                lyrics(i).word_position = SYLLABLE_WORDBEGIN;
            end
        
            
        % An end preceded by an end or single is a problem; make the second one a
        % single
        elseif ( ...
            ((lyrics(i-1).word_position == SYLLABLE_WORDEND) || (lyrics(i-1).word_position == SYLLABLE_SINGLESYLLABLE)) ...
            && ...
            (lyrics(i).word_position == SYLLABLE_WORDEND) ...
            )
            if (print_errors)
                fprintf(1,'8) Changing lyric %d (%s --> *%s*) (measure %d) to a single-syllable word\n',...
                    i,lyrics(i-1).text,lyrics(i).text, lyrics(i-1).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;

        % A begin followed by a begin or a single is a problem; change the first to a
        % single
        elseif ( ... 
            (lyrics(i+1).word_position == SYLLABLE_WORDBEGIN || lyrics(i+1).word_position == SYLLABLE_SINGLESYLLABLE) ...
            && ...
            (lyrics(i).word_position == SYLLABLE_WORDBEGIN) ...
            )     
            if (print_errors)
                fprintf(1,'9) Changing lyric %d (*%s* --> %s) (measure %d) to a single-syllable word\n',...
                    i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;
            
        % A continue followed by a begin or a single is a problem; change
        % the first to an end
        elseif ( ... 
            (lyrics(i+1).word_position == SYLLABLE_WORDBEGIN || lyrics(i+1).word_position == SYLLABLE_SINGLESYLLABLE) ...
            && ...
            (lyrics(i).word_position == SYLLABLE_WORDCONTINUATION) ...
            )     
            if (print_errors)
                fprintf(1,'10) Changing lyric %d (*%s* --> %s) (measure %d) to an end\n',...
                    i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
            end            
            lyrics(i).word_position = SYLLABLE_WORDEND;
            
        % A continue followed by a begin is a problem; change the first to an
        % end
        elseif ( ...
             (lyrics(i).word_position == SYLLABLE_WORDCONTINUATION) ...
             && ...
             (lyrics(i+1).word_position == SYLLABLE_WORDBEGIN) ...
             )     
            if (print_errors)
                fprintf(1,'11) Changing lyric %d (*%s* --> %s) (measure %d) to an end\n',...
                    i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
            end
            lyrics(i).word_position = SYLLABLE_WORDEND;
            
        % A continue preceded by an end or single is a problem
        %
        % Change the continue to a begin or single, depending on what comes
        % next
        elseif ( ...
            ((lyrics(i-1).word_position == SYLLABLE_WORDEND) || (lyrics(i-1).word_position == SYLLABLE_SINGLESYLLABLE)) ...
            && ...
            (lyrics(i).word_position == SYLLABLE_WORDCONTINUATION) ...
            )     
        
            % If we're followed by an end or continue, make this a begin
            if (lyrics(i+1).word_position == SYLLABLE_WORDCONTINUATION || lyrics(i+1).word_position == SYLLABLE_WORDEND)
                if (print_errors)
                    fprintf(1,'12) Changing lyric %d (%s --> *%s*) (measure %d) to a begin\n',...
                        i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
                end
                lyrics(i).word_position = SYLLABLE_WORDBEGIN;
                
            % If we're followed by a begin or single, make this a single
            else 
                if (print_errors)
                    fprintf(1,'13) Changing lyric %d (%s --> *%s*) (measure %d) to a single\n',...
                        i,lyrics(i).text,lyrics(i+1).text, lyrics(i).measure_number);
                end
                lyrics(i).word_position = SYLLABLE_SINGLESYLLABLE;
            end
            
        end
    
    end % This is not the first or last syllable
    
end

