function [Peaks,Input_Locs2] = RightToLeft(Input_Peaks,Input_Locs)
% Sorts the row vectors with peaks and their positions in an ascending
% order.
    [Peaks,Locs]=sort(Input_Peaks);
    for i=1:length(Locs)
        Input_Locs2(i)=Input_Locs(Locs(i));
    end
end