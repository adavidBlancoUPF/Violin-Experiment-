function flat_xml_measures = measures_from_xml(xml_data, part_id_to_extract)
% function flat_xml_measures = measures_from_xml(xml_data, part_id_to_extract)
%
% Expands out repeats in a score to give a single, flat sequence of 
% measures.  Not doing fancy stuff yet like coda processing, etc.
%
% Takes:
%
% xml_data: an xml tree as created by the Matlab XML tools, typically
% passed in from process_xml_data
%
%
% part_id_to_extract: the musicxml id of the part you're interested in, or
% '' (or nothing) if you just want the first part.
%
% Returns:
%
% flat_xml_measures: an list of xml structs in the same format as the input, but
% with measure objects expanded out to a flat list as per repeats.  Adds a 
% 'copy_number' field to each measure indicating which "version" of the
% measure it is, allowing us to distinguish measures that are actually
% in repeats.  Also adds an 'original_measure_number' field to make it
% easier to refer back into the original file.
%


% get score element
xml_score = getelements(xml_data,'score_partwise');
if (isempty(xml_score))
    fprintf('xml data contains no score\n');
    return;
end

% get part element (hopefully there is just one)
xml_part = getelements(xml_score,'part');
if (isempty(xml_part))
    fprintf('xml score contains no part\n');
    return;
end

% if more than one, just use the first
if (length(xml_part) > 1)
    if (length(part_id_to_extract)==0)
        fprintf('Warning: score has multiple parts\n');
        xml_part = xml_part(1);
    else
        foundpart = 0;
        
        % Find the part we're interested in
        for(partindex=1:length(xml_part))
            part = xml_part(partindex);
            partdata = part.data;
            if (isfield(partdata, 'id') == 0)
                fprintf(1,'Warning: part without part ID\n');
                continue;
            end
            partid = getfield(partdata, 'id');
            if (strcmpi(partid,part_id_to_extract)==1)
                fprintf(1,'Extracting part with id %s\n',partid);
                xml_part = xml_part(partindex);
                foundpart = 1;
                break;
            end
        end
        
        if (foundpart == 0)
            fprintf('Warning: score has multiple parts and I couldn''t find part %s\n', part_id_to_extract);
            xml_part = xml_part(1);
        end
    end
end

% get all measures
xml_measures = getelements(xml_part,'measure');
num_measures = length(xml_measures);

for(i=1:num_measures)
    xml_measures(i).copy_number = 1;
    xml_measures(i).original_measure_number = i;
end

% initialize the repeat and ending measures
repeat_measure = 1;
ending_measure = 0;

% The current measure index in our output (flat) score
flat_idx = 1;

% For every measure
for(i=1:num_measures)
    
    % Write this measure to the flat score and increment the index
    flat_xml_measures(flat_idx) = xml_measures(i);
    flat_idx = flat_idx + 1;

    
    % process barlines (there might be 2)
    xml_barlines = getelements(xml_measures(i),'barline');
    num_barlines = length(xml_barlines);
    
    for j=1:num_barlines
        % process endings
        xml_ending = getelements(xml_barlines(j),'ending');
        if (~isempty(xml_ending))            
            xml_ending_type = getattribute(xml_ending,'type');
            
            % beginning of an ending
            if (strfind(lower(xml_ending_type),'start'))
                ending_measure = i;
            end
            
            % end of an ending
            if (strfind(lower(xml_ending_type),'stop'))
                % hopefully there will be a repeat
                % hopefully another ending will begin the next measure
            end
            
            % all endings finished
            if (strfind(lower(xml_ending_type),'discontinue'))
                ending_measure = 0;
            end
        end
        
        % process repeats
        xml_repeat = getelements(xml_barlines(j),'repeat');    
        if (~isempty(xml_repeat))
            if (isfield(xml_repeat.data,'direction'))
                
                % beginning of a repeated section
                if (strfind(lower(xml_repeat.data.direction),'forward'))
                    repeat_measure = i;
                end
            
                % end of a repeated section
                if (strfind(lower(xml_repeat.data.direction),'backward'))
                    if (ending_measure)
                        % repeat until the ending measure
                        repeat_size = ending_measure - repeat_measure;
                        ending_measure = 0;
                    else
                        % repeat until the current measure
                        repeat_size = i - repeat_measure + 1;
                    end
                    
                    % copy measures and increment index accordingly
                    flat_xml_measures(flat_idx:flat_idx+repeat_size-1) = ...
                        xml_measures(repeat_measure:repeat_measure+repeat_size-1);
                    
                    % Increment the 'copy number' for all the measures we
                    % just copied
                    for(k=flat_idx:flat_idx+repeat_size-1)
                        flat_xml_measures(k).copy_number = flat_xml_measures(k).copy_number + 1;
                    end
                    
                    flat_idx = flat_idx + repeat_size;
                end
            end
        end
    end
end