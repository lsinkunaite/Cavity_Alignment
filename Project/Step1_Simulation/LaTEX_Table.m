function LaTEX_Table(bash_filename,input_filename)
% Eliminates spaces and replaces them with ampersands; adds two backslashes
% at the end of each line
    system(['./' strcat(bash_filename) ' ' strcat(input_filename)]);
end