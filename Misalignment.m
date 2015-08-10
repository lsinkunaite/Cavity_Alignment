function [Misalignment_Array]=Misalignment(tol_Index,Ratio_Matrix,pkr)
% (Sometimes) Finds misalignment parameter comparing the ratios of
% intensities
    Misalignment_Array=[];
    for Ratio_Iter=1:(size(Ratio_Matrix,1))
        [tfs,locations]=ismembertol(pkr,Ratio_Matrix(Ratio_Iter,:),tol_Index);
        %if ((length(unique(locations))) == (length(locations)))
        if (length(locations([true;diff(locations(:))>0])) == length(locations))
            if all(tfs);
                %Misalignment=[Misalignment Ratio_Matrix(Ratio_Iter,1)];
                Misalignment_Array=[Misalignment_Array Ratio_Iter];
            end
        end
    end
end