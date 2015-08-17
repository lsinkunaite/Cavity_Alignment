function [gouy_peaks,gouy_locs] = Gouy_Sort(pkr,locs,gouy_shift)
% Aligns the peaks in an ascending mode-order according to the single-trip Gouy phase.
    [max_pk,max_loc]=max(pkr);
    gouy_peaks(1)=max_pk;
    gouy_locs(1)=locs(max_loc);
    [gouy_locs,gouy_peaks]
    pkr(max_loc)=[];
    locs(max_loc)=[];
    for i=2:(length(locs)+1)
        [c_L2R,index_L2R]=min(abs(mod(locs-(gouy_locs(i-1)+gouy_shift),180)));
        [c_R2L,index_R2L]=min(abs(mod(locs-(gouy_locs(i-1)-gouy_shift),180)));
        if (c_R2L < c_L2R)
            [c,index]=min(abs(mod(locs-abs(gouy_locs(i-1)-gouy_shift),180)));
            gouy_locs(i)=locs(index);
            gouy_peaks(i)=pkr(index);
            pkr(find(pkr==(gouy_peaks(i))))=[];
            locs(find(locs==(gouy_locs(i))))=[];
            gouy_locs=circshift(gouy_locs,1,2);
            gouy_peaks=circshift(gouy_peaks,1,2);
            [gouy_locs,gouy_peaks]
        else
            [c,index]=min(abs(mod(locs-abs(gouy_locs(i-1)+gouy_shift),180)));
            gouy_locs(i)=locs(index);
            gouy_peaks(i)=pkr(index);
            pkr(find(pkr==(gouy_peaks(i))))=[];
            locs(find(locs==(gouy_locs(i))))=[];
            [gouy_locs,gouy_peaks]
        end
    end
end