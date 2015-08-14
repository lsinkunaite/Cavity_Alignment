function [gouy_peaks,gouy_locs] = Gouy_Left2Right(pkr,locs,gouy_shift)
% Aligns the peaks in an ascending mode-order according to the single-trip Gouy phase.
    [max_pk,max_loc]=max(pkr);
    gouy_peaks(1)=max_pk;
    gouy_locs(1)=locs(max_loc);
    for i=2:length(locs)
        if (gouy_locs(i-1)+gouy_shift)>180
            [c, index]= min(abs(locs-(gouy_locs(i-1)+gouy_shift-180)));
            gouy_locs(i)=(gouy_locs(i-1)+gouy_shift-180);
            gouy_peaks(i)=pkr(index);
            %fprintf('i = %d, loc(i) = %d, gouy_loc(i) = %f, gouy_peak= %f\n',i,locs(i),c,pkr(index));
        else
            [c, index]= min(abs(locs-(gouy_locs(i-1)+gouy_shift)));
            gouy_locs(i)=(gouy_locs(i-1)+gouy_shift);
            gouy_peaks(i)=pkr(index);
            %fprintf('i = %d, loc(i) = %d, gouy_loc(i) = %f, gouy_peak= %f\n',i,locs(i),c,pkr(index));
        end
    end
end