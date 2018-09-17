function [counter ] = mode_permutations_score(perms_array,score_ref,semitones, name,numberOfNotes,folder_name, counter)
%MODE_PERMUTATIONS_SCORE Summary of this function goes here
%   Detailed explanation goes here

measure = score_ref.score_dash_partwise.part.measure;

for i=1:length(perms_array)
    for j=1:size(perms_array,2)
        if j<5 
            compas = 2;
            negra = j;
        else
            compas = 3;
            negra = j - 4;
        end
        %measure{compas}.note{negra}.pitch.step.Text = semitones{perms_array(i,j)};
        note = struct;
        note.pitch.step.Text = semitones{perms_array(i,j)};
        note.duration.Text = '1';
        note.voice.Text = '1';
        note.type.Text = 'quarter';
        if (perms_array(i,j) == 1) ||  (perms_array(i,j) == 3) || (perms_array(i,j) == 6)
            note.pitch.alter.Text = '1';
            note.accidental.Text = 'sharp';
        end
        if perms_array(i,j) < 5 
            note.pitch.octave.Text = '3';
        else
            note.pitch.octave.Text = '4';
        end
        note.stem.Text = 'up';
        measure{compas}.note{negra} = note;
    end
    %audiowrite([[folder_name,'\',name],'\',num2str(i),'_',name,'_',num2str(counter),'.wav'],signal, fs);
    score_ref.score_dash_partwise.part.measure = measure;
    
    struct2xml(score_ref, [[folder_name,'\',name],'\',num2str(i),'_',name,'_',num2str(counter)])
    counter = counter + 1;
end


end

