function [gouy_peaks,gouy_locs] = Gouy_Sort(pkr,locs,gouy_shift)
% Sorts the peaks in an ascending mode-order according to the single-trip Gouy phase.
    [max_pk,max_loc]=max(pkr);
    gouy_peaks(1)=max_pk;
    gouy_locs(1)=locs(max_loc);
    pkr(max_loc)=[];
    locs(max_loc)=[];
    for i=2:(length(locs)+1)
        [c_L2R1,index_L2R1]=min(abs(mod(locs-(gouy_locs(end)+gouy_shift),180)));
        [c_L2R2,index_L2R2]=min(abs(mod((gouy_locs(end)+gouy_shift)-locs+180,180)));
        if (c_L2R1 <= c_L2R2)
            c_L2R=c_L2R1; index_L2R=index_L2R1;
        else
            c_L2R=c_L2R2; index_L2R=index_L2R2;
        end
        
        [c_R2L1,index_R2L1]=min(abs(locs-mod((gouy_locs(1)-gouy_shift),180)));
        [c_R2L2,index_R2L2]=min(abs(mod((gouy_locs(1)-gouy_shift),180)-locs+180));
    
        if (c_R2L1 <= c_R2L2)
            c_R2L=c_R2L1; index_R2L=index_R2L1;
        else
            c_R2L=c_R2L2; index_R2L=index_R2L2;
        end
        
        if (c_R2L <= c_L2R)
            index=index_R2L;
            gouy_locs(i)=locs(index);
            gouy_peaks(i)=pkr(index);
            pkr(find(pkr==(gouy_peaks(i))))=[];
            locs(find(locs==(gouy_locs(i))))=[];
            gouy_locs=circshift(gouy_locs,1,2);
            gouy_peaks=circshift(gouy_peaks,1,2);
        else
            index=index_L2R;
            gouy_locs(i)=locs(index);
            gouy_peaks(i)=pkr(index);
            pkr(find(pkr==(gouy_peaks(i))))=[];
            locs(find(locs==(gouy_locs(i))))=[];
        end
    end
end
