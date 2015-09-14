function [gouy_pkr,gouy_locs]=ToFlipOrNotToFlip(Interpolated_witness,Domain_From,Domain_To,gouy_pkr,gouy_locs)
% Flips order of the peak-ratio vector and their locations' vector if the cavity is being extended.
    % The mean value of the witness sensor
    Mean_witness=mean(Interpolated_witness(~isnan(Interpolated_witness)));
    % The value of witness sensor at the midpoint of the selected region
    Middle_witness=Interpolated_witness((round((Domain_To-Domain_From)/2))+Domain_From);
    
    % True if the region lies in the lower part of the witness distribution
    IsBelow=(Middle_witness<Mean_witness);
    % True if the gradient of the selected region is positive
    IsPositive=all((sign(diff(Interpolated_witness(Domain_From:Domain_To))))>0);
    if (xor(IsBelow,IsPositive))
        gouy_pkr=fliplr(gouy_pkr);
        gouy_locs=fliplr(gouy_locs);
    end
end