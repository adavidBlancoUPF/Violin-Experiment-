
numberOfNotes = 8;
[Y,fs] = audioread('ref.wav');
signal = zeros(fs*numberOfNotes,1);
signal(1:length(Y)) = Y; 
%signal(fs*(numberOfNotes+1)+1:fs*(numberOfNotes+1)+length(Y)) = Y;
folder_name = 'New_generated_melodies';
%1:Sol#
%2:La
%3:La#
%4:Si
%5:Do
%6:Do#
%7:Re
for i=1:7
    [x,fs] = audioread(['Original_Sounds\', num2str(i),'.wav']);
    Ynotes(i,:) = x(1:37000);  %Número aproximado de duración para cada audio. 
end



jonico = [2,4,5,7];
eolico = [2,3,5,7];
frigio = [1,3,5,7];
lidio  = [2,4,6,7];
locrio = [1,3,5,6];


counter = 0;
%permutaciones en jonico
perms_array = perms(jonico);
name = 'jonico';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);

counter = mode_permutations(perms_array,name, Ynotes, signal,fs,numberOfNotes,folder_name, counter);

%permutaciones en eolico
perms_array = perms(eolico);
name = 'eolico';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);

counter = mode_permutations(perms_array,name, Ynotes, signal,fs,numberOfNotes,folder_name, counter);

%permutaciones en frigio
perms_array = perms(frigio);
name = 'frigio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);

counter = mode_permutations(perms_array,name, Ynotes, signal,fs,numberOfNotes,folder_name, counter);

%permutaciones en lidio
perms_array = perms(lidio);
name = 'lidio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);

counter = mode_permutations(perms_array,name, Ynotes, signal,fs,numberOfNotes,folder_name, counter);

%permutaciones en locrio
perms_array = perms(locrio);
name = 'locrio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);

counter = mode_permutations(perms_array,name, Ynotes, signal,fs,numberOfNotes,folder_name, counter);