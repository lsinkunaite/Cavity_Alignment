function input_matrix=LowPass_Filter(input_matrix,polynomial,w)
% Applies a digital Butterworth filter.
    [b,a]=butter(polynomial,w);
    %freqz(b,a)
    input_matrix=filter(b,a,input_matrix);
end