function [new_data] = Decimator(old_data,r)
% Decimation reduces the original sampling rate of a sequence to a lower
% rate by a factor r.
    index=size(old_data,2);
    for i=1:index
        new_data(:,i)=decimate(old_data(:,i),r);
    end
end
