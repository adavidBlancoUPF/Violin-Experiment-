
numberOfNotes = 8;
score_ref = xml2struct('Score_ref.xml');
folder_name = 'New_generated_scores';

jonico = [2,4,5,7];
eolico = [2,3,5,7];
frigio = [1,3,5,7];
lidio  = [2,4,6,7];
locrio = [1,3,5,6];

semitones = {'G','A','A','B','C','C','D'};

counter = 1;
%permutaciones en jonico
perms_array = perms(jonico);
name = 'jonico';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en eolico
perms_array = perms(eolico);
name = 'eolico';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en frigio
perms_array = perms(frigio);
name = 'frigio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en lidio
perms_array = perms(lidio);
name = 'lidio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en locrio
perms_array = perms(locrio);
name = 'locrio';
%If we want to include repetitions for each note
perms_array = repelem(perms_array,1,2);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);
