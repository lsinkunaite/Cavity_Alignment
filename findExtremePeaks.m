function [extreme_pks,extreme_locs]=findExtremePeaks(input_pks,input_locs,x)
% Finds extreme peaks and their locations.
    extreme_pks=input_pks(input_pks>(mean(input_pks)+x*(std(input_pks))));
    extreme_locs=input_locs(input_pks>(mean(input_pks)+x*(std(input_pks))));
end