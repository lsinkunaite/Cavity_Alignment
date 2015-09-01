function [Dist_Gouy,Row_Gouy,Mode_Gouy]=TrueMisalignment(Ratio_Matrix,gouy_pks)
% Flips the input sequence, calls the Misalignment function, decides on the
% peak direction, and returns the true misalignment.
    fgouy_pks=fliplr(gouy_pks);
    [Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,gouy_pks);
    [fDist_Gouy,fRow_Gouy,fMode_Gouy]=Misalignment(Ratio_Matrix,fgouy_pks);
    if (fDist_Gouy<Dist_Gouy)
        Dist_Gouy=fDist_Gouy;Row_Gouy=fRow_Gouy;Mode_Gouy=fMode_Gouy;
    end
end