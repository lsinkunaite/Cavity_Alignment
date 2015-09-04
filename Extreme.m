function [Domain_From,Domain_To]=Extreme(input_matrix,input_matrix2,pks2,locs2,fraction)
% Defines boundaries of one cycle.
    Initial_length=length(pks2);
    Length=Initial_length;
    Counter=0;
    while (Counter==0)
        if (Initial_length~=Length)
            locs2(Max_loc)=[];pks2=input_matrix(locs2);
        end
        [Max_pk,Max_loc]=max(pks2);
        Max_pk1=Max_pk;Max_loc1=locs2(Max_loc);
        [Diff_pks,Diff_locs]=sort(Max_pk-pks2);
        pks=pks2(Diff_locs);
        Max_pk2=0;Max_loc2=0;
        Counter=0;
        Iterator=1;
        Slope_Array=[0 (diff(sign(diff(input_matrix)))~=0)' 0];
        while ((Counter== 0)&&(Iterator<=length(Diff_locs))&&(Diff_pks(Iterator)<(0.1*Max_pk1)))
            if ((((1-fraction)*180)<(abs(locs2(Diff_locs(Iterator))-Max_loc1))) && ((abs(locs2(Diff_locs(Iterator))-Max_loc1))<((1+fraction)*180)))
                Max_pk2=pks(Iterator);
                Max_loc2=locs2(Diff_locs(Iterator));
                if Max_loc1>Max_loc2
                    Max_loc1=find((Slope_Array(1:Max_loc1-1))~=0,1,'last');
                    Max_loc2=find((Slope_Array(1:Max_loc2-1))~=0,1,'last');
                else
                    Max_loc1=find((Slope_Array(Max_loc1+1:end))~=0,1)+Max_loc1-1;
                    Max_loc2=find((Slope_Array(Max_loc2+1:end))~=0,1)+Max_loc2-1;
                end
                Domain=sort([Max_loc1 Max_loc2]);
                if IsLinear(input_matrix2(Domain(1):Domain(2)))
                    Counter=1;
                end
            end
            Iterator=Iterator+1;
        end
        % Domain_From=Domain(1);Domain_To=Domain(2);
        Length=Length-1;
    end
    Domain_From=Domain(1);Domain_To=Domain(2);
end