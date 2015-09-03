function [Domain_From,Domain_To]=Extreme(input_matrix,pks,locs,fraction1,fraction2)
% Defines boundaries of one cycle.
    [Max_pk,Max_loc]=max(pks);
    Max_pk1=Max_pk;Max_loc1=locs(Max_loc);
    [Diff_pks,Diff_locs]=sort(Max_pk-pks);
    %Diff_locs=locs(Diff_locs);
    pks=pks(Diff_locs);
    Max_pk2=0;Max_loc2=0;
    Counter=0;
    Iterator=1;
    Slope_Array=[0 (diff(sign(diff(input_matrix)))~=0)' 0];
    while (Counter == 0)
        if ((((1-fraction2)*180)<(abs(locs(Diff_locs(Iterator))-Max_loc1))) && ((abs(locs(Diff_locs(Iterator))-Max_loc1))<((1+fraction2)*180)))
            Max_pk2=pks(Iterator);
            Max_loc2=locs(Diff_locs(Iterator));
            if Max_loc1>Max_loc2
                Max_loc1=find((Slope_Array(1:Max_loc1-1))~=0,1,'last');
                Max_loc2=find((Slope_Array(1:Max_loc2-1))~=0,1,'last');
            else
                Max_loc1=find((Slope_Array(Max_loc1+1:end))~=0,1)+Max_loc1-1;
                Max_loc2=find((Slope_Array(Max_loc2+1:end))~=0,1)+Max_loc2-1;
            end
            Counter=1;
        end
        Iterator=Iterator+1;
    end
    Domain=sort([Max_loc1 Max_loc2]);
    Domain_From=Domain(1);
    Domain_To=Domain(2);
end