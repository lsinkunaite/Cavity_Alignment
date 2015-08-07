function Ratio_Table(fitting_path,rTABLE_filename,results_filename2,Table_Matrix,bash_filename2)
% Prints relative ratios of power spectrum in a tabular form
    rTABLE=fopen(strcat(fitting_path,rTABLE_filename,results_filename2),'at');
    for Table_Iter_Row=1:size(Table_Matrix,1)
        if (size(Table_Matrix,2))>2
            T_Index_Iter=0;
            for Table_Iter=2:(size(Table_Matrix,2)-1)
                row_el=Table_Matrix(Table_Iter_Row,Table_Iter);
                for Table_Iter2=(Table_Iter+1):size(Table_Matrix,2)
                    row_el2=Table_Matrix(Table_Iter_Row,Table_Iter2);
                    T_Index_Iter=T_Index_Iter+1;
                    rTable_Matrix(T_Index_Iter)=row_el2/row_el;
                end
            end
        end
        fprintf(rTABLE, [num2str(Table_Matrix(Table_Iter_Row,1)) ' ' num2str(rTable_Matrix) '\n']);
    end
    fclose(rTABLE);
    LaTEX_Table(bash_filename2,strcat(fitting_path,rTABLE_filename,results_filename2));
end