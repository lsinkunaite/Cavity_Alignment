function [pks,locs] = findTruepeaks(input_matrix,antires,antispike)
% Finds peaks and their positions including the endpoints (excluding
% neighbouring peaks)
%     input_matrix2=zeros(1,length(input_matrix)+2);
%     input_matrix2(1,2:end-1)=input_matrix;
%     Diff_Left=input_matrix2(1,2:end-1)-input_matrix2(1,1:end-2);
%     Diff_Right=input_matrix2(1,2:end-1)-input_matrix2(1,3:end);
%     locs=find(Diff_Left > 0 & Diff_Right > 0);
    
    [pks,locs]=findpeaks(input_matrix);
    
%     figure;
%     subplot(4,1,1);
%     plot(input_matrix);
%     hold on;
%     plot(locs,input_matrix(locs),'vr');
%     title('peaks');
    
    locs((find(((diff(locs))<antires)&((diff(input_matrix(locs)))<=0)))+1)=[];
    
%     subplot(4,1,2);
%     plot(input_matrix);
%     hold on;
%     plot(locs,input_matrix(locs),'vr');
%     title('antires L2R');
    
    locs=fliplr(locs);
    pks=input_matrix(locs);
    locs((find(((abs(diff(locs)))<antires)&((diff(pks))<=0)))+1)=[];
    locs=fliplr(locs);
    pks=input_matrix(locs);
    
%     subplot(4,1,3);
%     plot(input_matrix);
%     hold on;
%     plot(locs,input_matrix(locs),'vr');
%     title('antires R2L');
    
    Slope_Array=[0 (diff(sign(diff(input_matrix)))==0) 0];
    prom(1)=pks(1)-(input_matrix(find((Slope_Array(locs(1)+1:end))==0,1)+locs(1)-1));
    prom(length(pks))=input_matrix(find((Slope_Array(1:locs(length(pks))-1))==0,1,'last'));
    for pk_iter=2:(length(pks)-1)
        pk_R=input_matrix(find((Slope_Array(locs(pk_iter)+1:end))==0,1)+locs(pk_iter)-1);
        pk_L=input_matrix(find((Slope_Array(1:locs(pk_iter)-1))==0,1,'last'));
        if (((length(pk_L))~=0)&&((length(pk_R))~=0))
            if ((pks(pk_iter)-pk_R)<(pks(pk_iter)-pk_L))
                prom(pk_iter)=pks(pk_iter)-pk_R;
            else
                prom(pk_iter)=pks(pk_iter)-pk_L;
            end
        else
            prom(pk_iter)=pks(pk_iter);
        end
    end

    %prom_ratio=prom/(max(prom));
    %locs(find(prom_ratio<antispike))=[];
    %pks=input_matrix(locs);
   
    prom_ratio=prom/(max(prom));
    InterSpace=length(input_matrix)/(length(pks));
    locs((find((prom_ratio(1:end-1)<antispike)&((sign(diff(pks)))<1)&((diff(locs))<InterSpace)))+1)=[];   
    pks=input_matrix(locs);
    
    
    Slope_Array=[0 (diff(sign(diff(input_matrix)))==0) 0];
    prom(1)=pks(1)-(input_matrix(find((Slope_Array(locs(1)+1:end))==0,1)+locs(1)-1));
    prom(length(pks))=input_matrix(find((Slope_Array(1:locs(length(pks))-1))==0,1,'last'));
    for pk_iter=2:(length(pks)-1)
        pk_R=input_matrix(find((Slope_Array(locs(pk_iter)+1:end))==0,1)+locs(pk_iter)-1);
        pk_L=input_matrix(find((Slope_Array(1:locs(pk_iter)-1))==0,1,'last'));
        if (((length(pk_L))~=0)&&((length(pk_R))~=0))
            if ((pks(pk_iter)-pk_R)<(pks(pk_iter)-pk_L))
                prom(pk_iter)=pks(pk_iter)-pk_R;
            else
                prom(pk_iter)=pks(pk_iter)-pk_L;
            end
        else
            prom(pk_iter)=pks(pk_iter);
        end
    end

    %prom_ratio=prom/(max(prom));
    %locs(find(prom_ratio<antispike))=[];
    %pks=input_matrix(locs);
   
    prom_ratio=prom/(max(prom));
    InterSpace=length(input_matrix)/(length(pks));
    locs((find((prom_ratio(1:end-1)<antispike)&((sign(diff(pks)))<1)&((diff(locs))<InterSpace)))+1)=[];   
    pks=input_matrix(locs);
    
%     
%     subplot(4,1,4);
%     plot(input_matrix);
%     hold on;
%     plot(locs,input_matrix(locs),'vr');
%     title('antispike');
    
    figure;
    plot(input_matrix);
    hold on;
    plot(locs, pks,'or');
    xlim([1 length(input_matrix)]);
    title('findTruepeaks');
end       
