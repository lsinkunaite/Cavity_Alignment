function plot_picking(input_matrix1,input_matrix2)
% Finds peaks and their positions including the endpoints
    locs=find(input_matrix1>=[input_matrix1(2:end) inf] & input_matrix1>[-inf input_matrix1(1:end-1)]);
    if (input_matrix1(1)<input_matrix1(end-1))
        locs=locs(2:end);
    end
    pks=input_matrix1(locs);
    figure;
    subplot(4,1,1);
    plot(input_matrix2(:,2)-input_matrix2(:,5));
    subplot(4,1,2);
    plot(input_matrix2(:,2)+input_matrix2(:,5));
    subplot(4,1,3);
    plot(input_matrix1);
    subplot(4,1,4);    
    plot(input_matrix1);
    hold on;
    plot(locs, pks,'or');
    xlim([0 (length(input_matrix1)-1)]);
end