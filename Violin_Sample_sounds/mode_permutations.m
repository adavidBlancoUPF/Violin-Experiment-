function counter = mode_permutations(perms_array,name, Ynotes, signal,fs, numberOfNotes, folder_name, counter)
%MODE_PERMUTATIONS Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(perms_array)
    for j=1:numberOfNotes
        signal((fs*j+1):(fs*j+length(Ynotes(perms_array(i,j),:)))) = Ynotes(perms_array(i,j),:);
%     signal((fs*2+1):(fs*2+length(Ynotes(perms_array(i,2),:)))) = Ynotes(perms_array(i,2),:);
%     signal((fs*3+1):(fs*3+length(Ynotes(perms_array(i,3),:)))) = Ynotes(perms_array(i,3),:);
%     signal((fs*4+1):(fs*4+length(Ynotes(perms_array(i,4),:)))) = Ynotes(perms_array(i,4),:);
    end
    audiowrite([folder_name,'\',num2str(counter,'%03.f'),'_',num2str(i,'%02.f'),'_',name,'.wav'],signal, fs);
    counter = counter + 1;
end


end

