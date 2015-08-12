function [Ratio_Matrix] = Ratio_Table(pkr,fitting_path,rTABLE_filename,results_filename2,Table_Matrix,bash_filename2)
% Prints relative power ratios in a tabular form. Reference point is the
% highest peak.
    rTABLE=fopen(strcat(fitting_path,rTABLE_filename,results_filename2),'at');
    for Table_Iter_Row=1:size(Table_Matrix,1)
        Ref_el=max(Table_Matrix(Table_Iter_Row,2:end));
        for Table_Iter_Column=1:(size(Table_Matrix,2)-1)
            rTable_Matrix(Table_Iter_Column)=(Table_Matrix(Table_Iter_Row,Table_Iter_Column+1))/Ref_el;
        end
        fprintf(rTABLE, [num2str(Table_Matrix(Table_Iter_Row,1)) ' ' num2str(rTable_Matrix) '\n']);
    end
    fclose(rTABLE);
    LaTEX_Table(bash_filename2,strcat(fitting_path,rTABLE_filename,results_filename2));
    Ratio_Matrix=csvread(strcat(fitting_path,rTABLE_filename,results_filename2));
end