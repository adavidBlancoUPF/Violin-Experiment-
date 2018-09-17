%
% flag_or_remove_duplicate_songs.m
%
% This script will flag and/or remove duplicates from all_songs, according
% to the (global) FLAG_PROBABLE_DUPLICATES and REMOVE_PROBABLE_DUPLICATES
% variables.
% 

% Just for debugging; make a backup copy of the whole array
% if (~exist('tmpsongs'))
%     tmpsongs = all_songs;
% end
% all_songs = tmpsongs;

fprintf(1,'\nRemoving duplicate songs...\n');

duplicated_filenames = {};

if (~(exist('FLAG_PROBABLE_DUPLICATES','var')))
    FLAG_PROBABLE_DUPLICATES = 1;
end

if (~(exist('REMOVE_PROBABLE_DUPLICATES','var')))
    REMOVE_PROBABLE_DUPLICATES = 0;
end


if (FLAG_PROBABLE_DUPLICATES || REMOVE_PROBABLE_DUPLICATES)

    % Sort by name, so we can cull duplicates
    [unused, order] = sort({all_songs(:).title});
    all_songs = all_songs(order); 

    indices_to_remove = [];
    n_songs = length(all_songs);
    for(i=2:n_songs)

        if (i >= length(all_songs))
            break;
        end

        if (1==strcmpi(all_songs(i).title,all_songs(i-1).title))

            % Keep the longer one (sort of arbitrary)
            if (length(all_songs(i).raw_chord_names) > length(all_songs(i-1).raw_chord_names))
                index_to_remove = i-1;
            else
                index_to_remove = i;
            end

            if (REMOVE_PROBABLE_DUPLICATES)
                action = 'culling';
            else
                action = 'flagging';
            end
            
            fprintf(1,'Songs %d and %d (from files %s (%d chords) and %s (%d chords))\n\tappear to be identical, title is %s, %s song %d\n', ...
                i-1, i, all_songs(i-1).filename, length(all_songs(i-1).raw_chord_names), ...
                all_songs(i).filename, length(all_songs(i).raw_chord_names), all_songs(i).title, action, index_to_remove);

            if (length(all_songs(i).raw_chord_names) ~= length(all_songs(i-1).raw_chord_names))
                fprintf(1,'Warning: these songs appear to have different numbers of chords (%d vs. %d)\n', ...
                length(all_songs(i).raw_chord_names), length(all_songs(i-1).raw_chord_names));
            end
                
            n_duplicated_filenames = size(duplicated_filenames,1);
            n_duplicated_filenames = n_duplicated_filenames + 1;
            duplicated_filenames{n_duplicated_filenames,1} = all_songs(i).filename;
            duplicated_filenames{n_duplicated_filenames,2} = all_songs(i-1).filename;
            
            if (REMOVE_PROBABLE_DUPLICATES)
                % Remove whichever one we didn't like
                all_songs(index_to_remove) = [];

                % Knock our index down by one to reflect the shift
                i = i - 1;
            else
                all_songs(index_to_remove).probable_duplicate = 1;
            end            
        end
    end
end

% Return everything to its original sorting
[unused, order] = sort(cell2mat({all_songs(:).index}));
all_songs = all_songs(order); 