function power_distance_plot(maxTEM,L_to,L_from,L_step,xvar_L,power_L,fitting_legend_string)
% Plots power for each HG mode for different bs positions
    for plotting_step=1:(maxTEM+1)
        figure(plotting_step);
        for step_int=plotting_step:(maxTEM+1):((((L_to-L_from)/L_step)+1)*(maxTEM+1))
            plot((xvar_L((step_int),:)),(power_L(:,step_int)));
            hold on;
        end
    
        xlabel('$${i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}$$','interpreter','latex');
        ylabel('Power [W]');
        title(sprintf('Power distribution of HG_{%d}_0 mode',plotting_step-1));
        grid on;
        set(legend(cellstr(strcat('L=',fitting_legend_string))), 'location', 'NorthEastOutside');
    end
end