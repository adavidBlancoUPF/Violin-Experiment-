

[Y,fs] = audioread('ref.wav');
signal = zeros(fs*4,1);
signal(1:length(Y)) = Y; 
folder_name = 'Generated_melodies';
%1:Sol#
%2:La
%3:La#
%4:Si
%5:Do
%6:Do#
%7:Re
for i=1:7
    [x,fs] = audioread([num2str(i),'.wav']);
    Ynotes(i,:) = x(1:37000);
end



jonico = [2,4,5,7];
eolico = [2,3,5,7];
frigio = [1,3,5,7];
lidio  = [2,4,6,7];
locrio = [1,3,5,6];

%permutaciones en jonico
perms_array = [];
for i=1:length(jonico)
    mode = jonico;
    mode(i) = [];
    perms_array = [perms_array;perms(mode)];
end


perms_array = perms(jonico);
name = 'jonico';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,3,2);

mode_permutations(perms_array,name, Ynotes, signal,fs,4,folder_name);

%permutaciones en eolico
perms_array = perms(eolico);
name = 'eolico';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,3,2);

mode_permutations(perms_array,name, Ynotes, signal,fs,4,folder_name);

%permutaciones en frigio
perms_array = perms(frigio);
name = 'frigio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,3,2);

mode_permutations(perms_array,name, Ynotes, signal,fs,4,folder_name);

%permutaciones en lidio
perms_array = perms(lidio);
name = 'lidio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,3,2);

mode_permutations(perms_array,name, Ynotes, signal,fs,4,folder_name);

%permutaciones en locrio
perms_array = perms(locrio);
name = 'locrio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,3,2);

mode_permutations(perms_array,name, Ynotes, signal,fs,4,folder_name);