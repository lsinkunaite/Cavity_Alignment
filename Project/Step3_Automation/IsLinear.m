function Output=IsLinear(Interpolated_Matrix_256)
% Checks if a function is linear in a given region. Output = 1, if yes, and
% Output = 0, if no.
    linear_length=length(find((diff(sign(diff(Interpolated_Matrix_256))))==0));
    full_length=length(diff(sign(diff(Interpolated_Matrix_256))));
    Output=(linear_length==full_length);
end