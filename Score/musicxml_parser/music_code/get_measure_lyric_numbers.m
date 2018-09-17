function lyric_numbers = get_measure_lyric_numbers(m)
%
% function get_measure_lyric_numbers(m)
%
% Returns a list of all the unique lyric numbers that appear in this
% measure.  'm' should be the xml toolbox structure for a measure of
% MusicXML.

lyric_numbers = [];

if (~(isfield(m,'sub')))
    fprintf(1,'Warning: measure %d has no sub content\n',m.original_measure_number);
    return;
end

if (isempty(m.sub))
    fprintf(1,'Warning: measure %d has no content\n',m.original_measure_number);
    return;
end

subnames = {m.sub.name};

% For every xml element in this measure...
for(j=1:length(m.sub))
    
   % If this is a note...
    if (strcmp(subnames{j},'note')) 
        
       n = m.sub(j);
       
       % Does this note have lyrics?
        lyricelements = getelements(n,'lyric');
        
        if (~(isempty(lyricelements)))

            % For all the lyric elements associated with this note
            for(lyricindex=1:length(lyricelements))

                lyricstruct = lyricelements(lyricindex);

                % Parse number and name information
                if (isfield(lyricstruct.data,'number'))
                   lyric_number = sscanf(lyricstruct.data.number,'%d');                       
                   lyric_numbers = [lyric_numbers lyric_number];
                end                                   

            end % for each individual lyric associated with this note

        end % if there are lyrics

    end % if this is a note
    
end % for every xml element in this measure

lyric_numbers = unique(lyric_numbers);
