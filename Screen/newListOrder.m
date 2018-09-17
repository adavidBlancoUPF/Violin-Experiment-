function [list_index] = newListOrder(List,Csv_list)
%NEWLISTORDER This functions gives the order in which we must read
% the scores according to the CSV file generated with random numbers

number = zeros(length(List),1);
for i=1:length(List)
    number(i) = str2double(List(i).name(1:3));    
end
    
Csv_list(:,2)








end

