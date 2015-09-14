function [new_data] = Interpolator(old_domain,new_domain,old_data)
% Interpolates data within a given range and returns a sample with new data
% points. Optional checks of different interpolation methods: linear,
% pchip, and spline.
%     plot(old_domain,old_data,'ob');
    method=char('linear','pchip','spline');
%     col={'--r',':g','-k'};
%     for k=1:(length(col))
%         new_data(k,:)=interp1(old_domain,old_data,new_domain,method(k,:));
%         hold on;
%         plot(new_domain,new_data(k,:),col{k})
%     end
    new_data=interp1(old_domain,old_data,new_domain,method(1,:));
end
