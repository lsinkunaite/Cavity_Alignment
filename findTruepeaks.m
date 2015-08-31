function [pks,locs] = findTruepeaks(input_matrix)
% Finds peaks and their positions including the endpoints (excluding
% neighbouring peaks)
    %locs=find(input_matrix>=[input_matrix(2:end) inf] & input_matrix>[-inf input_matrix(1:end-1)] & input_matrix>3);
    input_matrix2=zeros(1,length(input_matrix)+2);
    input_matrix2(1,2:end-1)=input_matrix;
    Diff_Left=input_matrix2(1,2:end-1)-input_matrix2(1,1:end-2);
    Diff_Right=input_matrix2(1,2:end-1)-input_matrix2(1,3:end);
    locs=find(Diff_Left > 0 & Diff_Right > 0);
    pks=input_matrix(locs);
%     
%     %figure;
%     plot(input_matrix);
%     hold on;
%     plot(locs, pks,'or');
%     xlim([0 (length(input_matrix)-1)]);
end