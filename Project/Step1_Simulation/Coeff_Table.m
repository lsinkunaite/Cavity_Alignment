% Generates table with mode decomposition coefficients
function Coeff_Table(input_filename,xvar,input_Matrix,output_filename,bash_filename)
% Prints out amplitude/power coefficient table
    fTABLE=fopen(input_filename,'at');
    for Table_Index=1:length(xvar)
        % Amplitude/power coefficients
        fprintf(fTABLE, [num2str(xvar(Table_Index)) ' ' num2str(input_Matrix(Table_Index,:)) '\n']);
    end
    fclose(fTABLE);
    LaTEX_Table(bash_filename,output_filename);
end
