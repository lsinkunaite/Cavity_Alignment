function [pks,locs] = findTruepeaks(input_matrix)
% Finds peaks and their positions including the endpoints (excluding
% neighbouring peaks)
    %locs=find(input_matrix>=[input_matrix(2:end) -inf] & input_matrix>[-inf input_matrix(1:end-1)]);
    locs=find(input_matrix>=[input_matrix(2:end) inf] & input_matrix>[-inf input_matrix(1:end-1)]);
    if (input_matrix(1)<input_matrix(end-1))
        locs=locs(2:end);
    end
    pks=input_matrix(locs);
    
    % Locations where slope changes its sign
    new_locs=(find((diff(sign(diff(input_matrix)))~=0)~=0))+1;
    new_pks=input_matrix(new_locs);
    
    
    figure;
    plot(input_matrix);
    hold on;
    plot(locs, pks,'or');
    xlim([0 (length(input_matrix)-1)]);
end