function [vi_pks,vi_locs]=findVIpeaks(pks,locs,N)
% Returns N highest peaks. Where length(pks)<N, returns length(pks) peaks.
    if ((length(pks))>N)
        [vi_pks,vi_locs]=sort(pks,'descend');
        vi_locs=locs(vi_locs);
        vi_locs=vi_locs(1:N);
        vi_pks=vi_pks(1:N);
    else     
        vi_pks=pks;vi_locs=locs;
    end
end