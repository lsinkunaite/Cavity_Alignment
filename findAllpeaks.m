function [pks,locs] = findAllpeaks(input_matrix)
% Finds peaks and their positions including the endpoints
    pks=find(input_matrix>=[input_matrix(2:end) -inf] & input_matrix>[-inf input_matrix(1:end-1)]);
    locs=input_matrix(pks);
end