function [perms_array] = perms_new(mode_input)
%PERMS_NEW Summary of this function goes here
%   Detailed explanation goes here

perms_array = [];
for i=1:length(mode_input)
    mode = mode_input;
    mode(i) = [];
    perms_array = [perms_array;perms(mode)];
end

end

