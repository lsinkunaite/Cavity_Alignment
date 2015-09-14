function Check_Transmittance(Ratio_Matrix,index,gouy_shift,code_path)
% Checks power transmittance and plots it against tuning
    R_etm=0.68; T_etm=0.32;
    R_itm=0.989; T_itm=0.011;
    r_e=sqrt(R_etm);
    r_i=sqrt(R_itm);

    
    T1_comb=0;
    for i=2:length(Ratio_Matrix(index,:))
    %for i=2:2
        for Phi=0:180
            % (-ve) Gouy phase flips the sign
            T1(Phi+1)=T_etm*T_itm/(power(abs(1-(sqrt(R_etm*R_itm)*exp(-1i*(Phi-(gouy_shift*(i-2)))*2*pi/180))),2));
        end
        T1_comb=T1_comb+(Ratio_Matrix(index,i))*T1;
    end

    figure20=figure;
    phi=0:180;
    plot(phi,T1_comb,'b');
    xlabel('ETM tuning [deg]');
    ylabel('Power [W]');
    title('Calculated transmittance');
    xlim([0 length(phi)]);
    % saveas(figure20,strcat(code_path,'Output/transmittance.epsc'));
    % saveas(figure20,strcat(code_path,'Output/transmittance.fig'));
    % saveas(figure20,strcat(code_path,'Output/transmittance.jpg'));
    % saveas(figure20,strcat(code_path,'Output/transmittance.pdf'));
end
