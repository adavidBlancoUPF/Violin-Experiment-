function measures = merge_measures(mlist1,mlist2)
%
% function measures = merge_measures(m1,m2)
%
% Takes two lists of MusicXML measures, in the struct array format
% returned by the Matlab XML toolbox, and merges them.  Returns []
% if there are any inconsistencies that prevent a clean merge;
% this is intended only for merging multiple parts from the same song.
%

if (length(mlist1) ~= length(mlist2))
    fprintf(1,'Can''t merge measure arrays of different lengths...\n');
    measures = [];
    return;
end

for(curm=1:length(mlist1))
    measures(curm) = mlist1(curm);
    m1 = mlist1(curm);
    m2 = mlist2(curm);
    
    if (m1.original_measure_number ~= m2.original_measure_number)
        fprintf(1,'Can''t reconcile differing measure numbers...\n');
        measures = [];
        return;
    end
    
    if (m1.copy_number ~= m2.copy_number)
        fprintf(1,'Can''t reconcile differing copy numbers...\n');
        measures = [];
        return;
    end
    
end