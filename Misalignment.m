function [Min_Dist,Mis_Row,Mis_Mode] = Misalignment(Ratio_Matrix,sorted_pkr)
% Returns misalignment parameter
    Mis_Row=0;
    Mis_Mode=0;
    Min_Dist=inf;
    for RRow_Iter=1:(size(Ratio_Matrix,1))
        for RColumn_Iter=1:(size(Ratio_Matrix,2)-length(sorted_pkr))
            Dist=0;
            for pkr_Iter2=1:length(sorted_pkr)
                Dist=Dist+power(sorted_pkr(pkr_Iter2)-Ratio_Matrix(RRow_Iter,RColumn_Iter+pkr_Iter2),2);
            end
            Inter_Dist=power(Dist,.5);
            %fprintf('Row = %d, Mode = %d, Inter_Dist = %f, Min_Dist = %f\n',RRow_Iter,RColumn_Iter-1,Inter_Dist,Min_Dist);
            if (Inter_Dist<Min_Dist)
                Min_Dist=Inter_Dist;
                Mis_Row=RRow_Iter;
                Mis_Mode=RColumn_Iter-1;
            end
        end
    end
end