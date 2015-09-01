function [Domain_From_new,Domain_To_new]=Extreme(input_matrix,pks,locs,fraction1,fraction2)
% Defines boundaries of one cycle.
    [extreme_pks,extreme_locs]=findExtremePeaks(pks,locs,fraction1);
    [extreMax_pk,extreMax_loc]=max(extreme_pks);
    Max_pk1=extreMax_pk;Max_loc1=extreme_locs(extreMax_loc);
    [extremeDiff_pks,extremeDiff_locs]=sort(extreMax_pk-extreme_pks);
    extremeDiff_locs=extreme_locs(extremeDiff_locs);
    Max_pk2=0;Max_loc2=0;
    Counter=0;
    another_iter=1;
    while (Counter == 0)
        if ((((1-fraction2)*180)<(abs(extremeDiff_locs(another_iter)-Max_loc1))) && ((abs(extremeDiff_locs(another_iter)-Max_loc1))>(fraction2*180)))
            Max_pk2=extremeDiff_pks(another_iter);
            Max_loc2=extremeDiff_locs(another_iter);
            if Max_loc1>Max_loc2
                %Max_loc1=Max_loc1-1;
                Slope_Array=[0 (diff(sign(diff(input_matrix)))==0)' 0];
                Max_loc1=find((Slope_Array(1:Max_loc1-1))==0,1,'last');
                Max_loc2=find((Slope_Array(Max_loc2+1:end))==0,1)+Max_loc2-1;
            else
                %Max_loc1=Max_loc1+1;
                Slope_Array=[0 (diff(sign(diff(input_matrix)))==0)' 0];
                Max_loc1=find((Slope_Array(Max_loc1+1:end))==0,1)+Max_loc1-1;
                Max_loc2=find((Slope_Array(1:Max_loc2-1))==0,1,'last');
            end
            Counter=1;
        end
        another_iter=another_iter+1;
    end


%     for another_iter=1:(length(extremeDiff_pks))
%         if ((((1-fraction2)*180)<(abs(extreme_locs(another_iter)-Max_loc1))) && ((abs(extreme_locs(another_iter)-Max_loc1))>(fraction2*180)))
%             Max_pk2=extreme_pks(another_iter);
%             Max_loc2=extreme_locs(another_iter);
%             if Max_loc1>Max_loc2
%                 Max_loc1=Max_loc1-1;
%             else
%                 Max_loc1=Max_loc1+1;
%             end
%             break;
%         end
%     end
    Domain_new=sort([Max_loc1 Max_loc2]);
    Domain_From_new=Domain_new(1);
    Domain_To_new=Domain_new(2);
end