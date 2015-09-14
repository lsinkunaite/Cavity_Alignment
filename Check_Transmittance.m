function Check_Transmittance(Ratio_Matrix,index,gouy_shift)
% Checks power transmittance and plots it against tuning
    R_etm=0.68; T_etm=0.32;
    R_itm=0.989; T_itm=0.011;
    r_e=sqrt(R_etm);
    r_i=sqrt(R_itm);

    %[c, index]= min(abs(Ratio_Matrix(:,1)-xvar));
    
    T1_comb=0;
    for i=2:length(Ratio_Matrix(index,:))
    %for i=2:2
        for Phi=0:180
            % (-ve) Gouy phase flips the sign
            T1(Phi+1)=T_etm*T_itm/(power(abs(1-(sqrt(R_etm*R_itm)*exp(-1i*(Phi-(gouy_shift*(i-2)))*2*pi/180))),2));
        end
        T1_comb=T1_comb+(Ratio_Matrix(index,i))*T1;
    end

%     T2_comb=0;
%     for j=2:length(Ratio_Matrix(index,:))
%         for Phi=0:180
%             T2(Phi+1)=T_etm*T_itm/(1+power(-R_etm*R_itm*exp(-1i*(Phi+(gouy_shift*(j-2)))),2));
%         end
%         T2_comb=T2_comb+(Ratio_Matrix(index,j))*T2;
%     end
    
    figure;
    phi=0:180;
    plot(phi,T1_comb,'b');
%     hold on;
%     plot(phi,T2_comb,'-b');
end