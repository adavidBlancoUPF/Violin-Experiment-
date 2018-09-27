
% This script produces different *.csv files, each one with different orders 
% of the generated melodies that are used as stimuli for the participants. 

%cd New_generated_melodies
f_struct = dir('New_generated_melodies');

names = cell([(length(f_struct)-2) 3]) ;

for i=1:length(names)
    names{i,1} = f_struct(i+2).name(1:3);
    names{i,2} = f_struct(i+2).name(5:6);
    names{i,3} = f_struct(i+2).name(8:end);
end



%Randomize melodies in "jonico"
modesNames = names(1:end,3);
jonico_index = find(strcmp(modesNames(:),'jonico.wav'));
jonico_index_rand = jonico_index(randperm(length(jonico_index)));
jonico_index_rand_reshaped = reshape(jonico_index_rand,[6,4]);


%Randomize melodies in "eolico"
modesNames = names(1:end,3);
eolico_index = find(strcmp(modesNames(:),'eolico.wav'));
eolico_index_rand = eolico_index(randperm(length(eolico_index)));
eolico_index_rand_reshaped = reshape(eolico_index_rand,[6,4]);


%Randomize melodies in "frigio"
modesNames = names(1:end,3);
frigio_index = find(strcmp(modesNames(:),'frigio.wav'));
frigio_index_rand = frigio_index(randperm(length(frigio_index)));
frigio_index_rand_reshaped = reshape(frigio_index_rand,[6,4]);


%Randomize melodies in "lidio"
modesNames = names(1:end,3);
lidio_index = find(strcmp(modesNames(:),'lidio.wav'));
lidio_index_rand = lidio_index(randperm(length(lidio_index)));
lidio_index_rand_reshaped = reshape(lidio_index_rand,[6,4]);


%Randomize melodies in "locrio"
modesNames = names(1:end,3);
locrio_index = find(strcmp(modesNames(:),'locrio.wav'));
locrio_index_rand = locrio_index(randperm(length(locrio_index)));
locrio_index_rand_reshaped = reshape(locrio_index_rand,[6,4]);

final_mat = zeros(6*5, 4);
j=1;
for i=1:length(jonico_index_rand_reshaped)
    final_mat(j,:) = jonico_index_rand_reshaped(i,:);
    final_mat(1+j,:) = eolico_index_rand_reshaped(i,:);
    final_mat(2+j,:) = frigio_index_rand_reshaped(i,:);
    final_mat(3+j,:) = lidio_index_rand_reshaped(i,:);
    final_mat(4+j,:) = locrio_index_rand_reshaped(i,:);
    j = j + 5;
end


v = [1:120]';

rand_note = 2*randi(4,1,120)';
final_mat = final_mat';
final_mat = final_mat(:);
v = [v final_mat rand_note];

csvwrite('random_file8.csv',v)