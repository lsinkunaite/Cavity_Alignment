function [Min_Dist,Mis_Row,Mis_Mode] = Misalignment(Ratio_Matrix,sorted_pkr)
% Uses minimisation to return the normalised misalignment parameter
    Mis_Row=0;
    Mis_Mode=0;
    Min_Dist=inf;
    for RRow_Iter=1:(size(Ratio_Matrix,1))
        if (length(sorted_pkr)<(size(Ratio_Matrix,2)))
            for RColumn_Iter=1:(size(Ratio_Matrix,2)-length(sorted_pkr))
                Dist=0;
                for pkr_Iter2=1:length(sorted_pkr)
                    Dist=Dist+power(sorted_pkr(pkr_Iter2)-Ratio_Matrix(RRow_Iter,RColumn_Iter+pkr_Iter2),2);
                end
                Inter_Dist=power(Dist,.5);
                if (Inter_Dist<Min_Dist)
                    Min_Dist=Inter_Dist;
                    Mis_Row=RRow_Iter;
                    Mis_Mode=RColumn_Iter-1;
                end
            end
        else
            for RColumn_Iter=1:(length(sorted_pkr)-size(Ratio_Matrix,2)+2)
                Dist=0;
                for pkr_Iter2=2:(size(Ratio_Matrix,2))
                    Dist=Dist+power(Ratio_Matrix(RRow_Iter,pkr_Iter2)-sorted_pkr(RColumn_Iter+pkr_Iter2-2),2);
                end
                Inter_Dist=power(Dist,.5);
                if (Inter_Dist<Min_Dist)
                    Min_Dist=Inter_Dist;
                    Mis_Row=RRow_Iter;
                    Mis_Mode=0;
                end
            end
        end
    end
    Mis_Mode=Mis_Mode+(find(sorted_pkr==1))-1;
end
