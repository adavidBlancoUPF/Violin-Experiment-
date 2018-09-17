function e = getelements(element,name)
%
% function e = getelements(element,name)
%
% Gets xml elements (structs) with name 'name' from the xml element (struct) 'element'
%

if (~isfield(element,'sub'))
    % fprintf(1,'Error: no sub element available\n');
    e = [];
    return;
end

if (isempty(element.sub))
    e = [];
    return;
end

if (~isfield(element.sub,'name'))
    % fprintf(1,'Error: no sub.name element available\n');
    e = [];
    return;
end

names = {element.sub.name};

nelements = 0;

for(i=1:length(names))
   if (strcmp(names{i},name))
       nelements = nelements + 1;
       e(nelements) = element.sub(i);
   end
end

if (nelements == 0) e = []; end;


