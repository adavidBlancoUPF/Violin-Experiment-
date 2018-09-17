function index = note_index_from_name(name)

name = lower(name);
define_music_globals;

for(i=1:length(sharp_key_names))
    if (strcmp(name,sharp_key_names{i}))
        index = i-1;
        return;
    end
end

fprintf(1,'\n\nError: unknown note name %s\n\n',name);

index = -1;