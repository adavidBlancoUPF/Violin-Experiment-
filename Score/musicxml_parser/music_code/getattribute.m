function val = getattribute(element,name)
%
% function val = getattribute(element,name)
%
% Gets value of xml attribute with name 'name' from the xml element
% (struct) 'element'
%
% Returns [] if the field [name] does not exist.
%

if (isfield(element.data,name))
    val = getfield(element.data,name);
else
    val = [];
end