%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                  %
%        HG mode decomposition coefficients        %
%                                                  %
%  lumos.m: runs Finesse file and varies the angle %
%  of misalignment of the bs/itm. Outputs the      %
%  power of each mode up to maxTEM+1 and prints    %
%  out the decomposition coefficients.             %
%                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

finesse_filename='freise'; % Finesse filename w/o extension
finesse_filepath='/home/laura/Finesse2.0/Misalignment/kat'; % Path to kat.ini

% Misalignment angle
theta_from=0; theta_to=0.00001; theta_step=0.000001;

maxTEM=5; % # of modes to be analysed: maxTEM+1
poly_degree_plot=8; % Degree of polynomial fit for plotting
poly_degree_fit=10; % Degree of polynomial fit for calculations
% Uniqueness condition for poly-fit
% if poly_degree_fit >= ((theta_to/theta_step)+1)
%     poly_degree_fit=(theta_to/theta_step) + 1;
% end
%poly_degree_array=linspace(1,maxTEM,maxTEM+1);
% Even-mode-only fitting
poly_degree_array=linspace(0,(poly_degree_fit-mod(poly_degree_fit,2)),((poly_degree_fit-mod(poly_degree_fit,2))/2)+1);

R_etm = 2241.54;
%R_itm = 1939.3;
R_itm = 99999999999;
tL = 2158.28; % Distance to the beam waist
L = 2158.28; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
% Divergence angle
alpha0 = (power((lambda/pi),.5))*(power((abs((R_etm+R_itm-(2*tL)))),.5))/(power((abs(tL*(R_etm-tL)*(R_itm-tL)*(R_etm+R_itm-tL))),.25));

% Tilting angle
alphaITM = (theta_from:theta_step:theta_to);
alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(length(alphaITM), (maxTEM+1));

%% Adds higher-order TEM modes to Finesse script

for j = 1:length(alphaITM)
    fID=fopen(strcat(finesse_filename,'kat.txt'), 'w');
    fprintf(fID, 's sarm %f n0 n1\n', L);
    fprintf(fID, 'attr bs1 xbeta %f\n', alphaITM(j));
    
    alpha(j) = alphaITM(j) * 2 / alpha0; % alpha/alpha0
    a(j) = alphaITM(j) * (L-tL) / w0; % a/w0
    xvar(j) = power((power(alpha(j),2) + power(a(j),2)),.5);
    
    % Generates HG modes
    for ii=0:maxTEM
        fprintf(fID, ['ad ad' num2str(ii) '0 ' num2str(ii) ' 0 0 n2\n']);
    end
    fclose(fID);
    system(sprintf('cat %s.kat %skat.txt > %sout.kat', finesse_filename, finesse_filename, finesse_filename));
    system(sprintf('%s %sout', finesse_filepath, finesse_filename));
    results=load(strcat(finesse_filename,'out.out'));
    TEMmatrix(j, :)=results(1, 3:end); 
end


%% Fitting with a predefined-order polynomial

% Generates power matrix
powerMatrix=zeros(length(alphaITM), maxTEM+1);
for TEMorder=0:maxTEM
    powerMatrix(:,TEMorder+1) = TEMmatrix(:,TEMorder+1).^2;
end
totalpower=sum(powerMatrix, 2);

results_filename1 = 'fit_results_';
results_filename2 = '.txt';
figure_filename2 = '.jpg';
fFIT_filename = 'fit_match_';
fitting_path = '/home/laura/Finesse2.0/Misalignment/Fitting/';
for k=1:(length(powerMatrix(1,:)))
    p(k,:)=polyfit(xvar',powerMatrix(:,k),poly_degree_plot);
    fFIT=fopen(sprintf('%s%s%i%s',fitting_path,fFIT_filename,k,results_filename2), 'w');
    for l=1:(length(poly_degree_array))
        % Prints fitting results to a text file
        fprintf(fFIT, [num2str(polyfit(xvar',powerMatrix(:,k),poly_degree_array(l))) '\n']);
    end
    fclose(fFIT);
    
    % Tests goodness-of-fit
    f(k,:)=polyval(p(k,:),xvar');
    T = table(xvar',powerMatrix(:,k),(f(k,:))',(powerMatrix(:,k)-(f(k,:))'),'VariableNames',{'X','Y','Fit','FitError'});
    results_filename = sprintf('%s%s%i%s',fitting_path, results_filename1, k, results_filename2);
    writetable(T,results_filename,'Delimiter',' ');
    
    % Plots the power and poly-fit for each HG-mode
    figure_file = figure;
    figure_filename = sprintf('%s%i%s',results_filename1, k, figure_filename2);
    figure_axes=axes('Parent', figure_file);
    hold(figure_axes,'all');
    plot(xvar, powerMatrix(:,k), 'x-');
    hold on;
    plot(xvar, f(k,:),'r--');
    xlabel('$${i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}$$','interpreter','latex');
    ylabel('Power [W]');
    title(sprintf('Power distribution of HG_{%d}_0 mode',k-1));
    saveas(figure_file, sprintf('%s%s',fitting_path, figure_filename));
end

%% Plots power distribution for higher-order HG-modes

figure;
plot(xvar, totalpower, 'r-');
hold on
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