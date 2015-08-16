function [pks,locs] = findAllpeaks(input_matrix)
% Finds peaks and their positions including the endpoints
    %locs=find(input_matrix>=[input_matrix(2:end) -inf] & input_matrix>[-inf input_matrix(1:end-1)]);
    locs=find(input_matrix>=[input_matrix(2:end) inf] & input_matrix>[-inf input_matrix(1:end-1)]);
    if (input_matrix(1)<input_matrix(end-1))
        locs=locs(2:end);
    end
    pks=input_matrix(locs);
    figure;
    plot(input_matrix);
    hold on;
    plot(locs, pks,'or');
    xlim([0 (length(input_matrix)-1)]);
end