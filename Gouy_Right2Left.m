function [gouy_peaks,gouy_locs] = Gouy_Right2Left(pkr,locs,gouy_shift)
% Aligns the peaks in a descending mode-order according to the single-trip Gouy phase.
    [max_pk,max_loc]=max(pkr);
    gouy_peaks(length(pkr))=max_pk;
    gouy_locs(length(locs))=locs(max_loc);
    for i=(length(locs)-1):-1:1
        if (gouy_locs(i+1)-gouy_shift)<0
            [c, index]= min(abs(locs-(gouy_locs(i+1)-gouy_shift+180)));
            gouy_locs(i)=(gouy_locs(i+1)-gouy_shift+180);
            gouy_peaks(i)=pkr(index);
            %fprintf('i = %d, loc(i) = %d, gouy_loc(i) = %f, gouy_peak= %f\n',i,locs(i),c,pkr(index));
        else
            [c, index]= min(abs(locs-(gouy_locs(i+1)-gouy_shift)));
            gouy_locs(i)=(gouy_locs(i+1)-gouy_shift);
            gouy_peaks(i)=pkr(index);
            %fprintf('i = %d, loc(i) = %d, gouy_loc(i) = %f, gouy_peak= %f\n',i,locs(i),c,pkr(index));
        end
    end
end