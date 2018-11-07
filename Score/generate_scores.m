
numberOfNotes = 3;
score_ref = xml2struct('Score_ref.xml');
folder_name = 'New_generated_scores';

jonico = [2,4,5,7];
eolico = [2,3,5,7];
frigio = [1,3,5,7];
lidio  = [2,4,6,7];
locrio = [1,3,5,6];

semitones = {'G','A','A','B','C','C','D'};

counter = 0;
%permutaciones en jonico
perms_array = perms(jonico);
name = 'jonico';
perms_array = perms_array(:,1:3);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en eolico
perms_array = perms(eolico);
name = 'eolico';
perms_array = perms_array(:,1:3);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en frigio
perms_array = perms(frigio);
name = 'frigio';
perms_array = perms_array(:,1:3);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en lidio
perms_array = perms(lidio);
name = 'lidio';
perms_array = perms_array(:,1:3);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);


%permutaciones en locrio
perms_array = perms(locrio);
name = 'locrio';
perms_array = perms_array(:,1:3);
mkdir(['New_generated_scores\',name])
counter = mode_permutations_score(perms_array,score_ref,semitones,name,numberOfNotes,folder_name, counter);
