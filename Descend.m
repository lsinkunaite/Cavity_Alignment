function [Peaks,Input_Locs2] = Descend(Input_Peaks,Input_Locs)
% Sorts the row vectors with peaks and their positions in a descending
% order.
    [Peaks,Locs]=sort(Input_Peaks);
    Peaks=fliplr(Peaks);
    Locs=fliplr(Locs);
    for i=1:length(Locs)
        Input_Locs2(i)=Input_Locs(Locs(i));
    end
end