function HG_modes_plot(xvar,totalpower,maxTEM,powerMatrix)
% Plots power distribution for higher-order HG-modes
    figure;
    plot(xvar, totalpower, 'r-');
    hold on;
    legend_order = linspace(0,maxTEM,maxTEM+1);
    legend_string={'total'};
    for ii=1:(maxTEM+1)
        plot(xvar, powerMatrix(:, ii), 'x-');
        %xlabel('$${i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}$$','interpreter','latex', 'fontsize', 14);
        xlabel('$${i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}$$','interpreter','latex');
        ylabel('Power [W]');
        title('Power distribution of different HG modes');
        legend_string{ii+1}=num2str(ii-1);
    end
    set(legend(cellstr(strcat('HG_{',legend_string,'}_0'))), 'location', 'NorthEastOutside');
end