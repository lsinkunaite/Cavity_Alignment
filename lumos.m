%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                  %
%        HG mode decomposition coefficients        %
%                                                  %
%  lumos.m: runs Finesse file and varies the angle %
%  of misalignment of the bs/itm. Outputs the      %
%  power of each mode up to maxTEM+1 and prints    %
%  out the fitting coefficients.                   %
%                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

finesse_filename='freise'; % Finesse filename w/o extension
finesse_filepath='/home/laura/Finesse2.0/Misalignment/kat'; % Path to kat.ini
code_path='/home/laura/Finesse2.0/Misalignment/';

maxTEM=2; % # of modes to be analysed: maxTEM+1
poly_degree_plot=8; % Degree of polynomial fit for plotting
poly_degree_fit=10; % Degree of polynomial fit for calculations
% Uniqueness condition for poly-fit
% if poly_degree_fit >= ((theta_to/theta_step)+1)
%     poly_degree_fit=(theta_to/theta_step) + 1;
% end
%poly_degree_array=linspace(1,maxTEM,maxTEM+1);
% Even-mode-only fitting
poly_degree_array=linspace(0,(poly_degree_fit-mod(poly_degree_fit,2)),((poly_degree_fit-mod(poly_degree_fit,2))/2)+1);

tL = 2158.28; % Distance to the beam waist
L = 3000.00; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
%R_itm = 1939.3;

% Deleting old files
for output_file=0:(maxTEM)
    if exist(sprintf('Fitting/fitting_HG%s0.txt',num2str(output_file)), 'file')
        delete(sprintf('Fitting/fitting_HG%s0.txt',num2str(output_file)));
    end
end

% Tilting angle theta
theta_from0=0; theta_to0=0.00001; theta_bin = 51;

alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin, (maxTEM+1));


% Distance to the mirror
L_bin=2;
%L_from=2200.00; L_to=12200.00; L_step=1000.00;
L_from=tL; L_to=24400.00; L_step=(L_to-L_from)/L_bin;
xvar_L=zeros((((L_to-L_from)/L_step)+1)*(maxTEM+1), theta_bin);
power_L=zeros(theta_bin,(((L_to-L_from)/L_step)+1)*(maxTEM+1));


L_itr = 0;
for L = L_from:L_step:L_to
    L_itr = L_itr+1;
    
    % Radius of curvature of bs/mirror
    if (L ~= tL)
        R_itm = (L-tL)*(1+power((pi*(power(w0,2))/(lambda*(L-tL))),2));
    else
        R_itm = 99999999999;
    end
    
    % Divergence angle
    %alpha0 = (power((lambda/pi),.5))*(power((abs((R_etm+R_itm-(2*L)))),.5))/(power((abs(L*(R_etm-L)*(R_itm-L)*(R_etm+R_itm-L))),.25));
    alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));
    
    theta_constant=power((1+(power((alpha0/w0),2))*(power(L,2)-(2*L*tL)+power(tL,2))),(.5)); 
    theta_to=theta_to0/theta_constant; theta_from=theta_from0;
    theta_step=(theta_to-theta_from)/(theta_bin-1);
    alphaITM = (theta_from:theta_step:theta_to);
    
    
    
    %% Adds higher-order TEM modes to Finesse script

    for j = 1:length(alphaITM)
        fID=fopen(strcat(finesse_filename,'kat.txt'), 'w');
        fprintf(fID, 's sarm %f n0 n1\n', L);
        fprintf(fID, 'attr bs1 Rc %f\n', R_itm);
        fprintf(fID, 'attr bs1 xbeta %.12f\n', alphaITM(j));
        fprintf(fID, 'maxtem %d\n', maxTEM);

        alpha(j) = alphaITM(j) * 2 / alpha0; % alpha/alpha0
        a(j) = alphaITM(j) * 2 * (L-tL) / w0; % a/w0
        xvar(j) = power((power(alpha(j),2) + power(a(j),2)),.5);

        
        % Generates HG mode
        for ii=0:maxTEM
            fprintf(fID, ['ad ad' num2str(ii) '0 ' num2str(ii) ' 0 0 n1\n']);
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
        
        % Writes fitting data into separate files for each polynomial
        fFIT_mode=fopen(sprintf('%sfitting_HG%i0.txt',fitting_path,k-1),'at');
        fprintf(fFIT_mode, [num2str(L), ' ',num2str(polyfit(xvar',powerMatrix(:,k),poly_degree_array(length(poly_degree_array)))) '\n']);
        fclose(fFIT_mode);
        
        % Tests goodness-of-fit
    %     f(k,:)=polyval(p(k,:),xvar');
    %     T = table(xvar',powerMatrix(:,k),(f(k,:))',(powerMatrix(:,k)-(f(k,:))'),'VariableNames',{'X','Y','Fit','FitError'});
    %     results_filename = sprintf('%s%s%i%s',fitting_path, results_filename1, k, results_filename2);
    %     writetable(T,results_filename,'Delimiter',' ');

    %xvar_L(L_itr+(k-1),:)=xvar;
    %power_L(:,L_itr+(k-1))=powerMatrix(:,1);
        
        %xvar_L((k+((((L_to-L_from)/L_step))*(L_itr-1))),:)=xvar;
        %power_L(:,(k+((((L_to-L_from)/L_step))*(L_itr-1))))=powerMatrix(:,k);     
        xvar_L((k+(maxTEM+1)*(L_itr-1)),:)=xvar;
        power_L(:,(k+(maxTEM+1)*(L_itr-1)))=powerMatrix(:,k);
        
 
    %     % Plots the power and poly-fit for each HG-mode
    %     figure_file = figure;
    %     figure_filename = sprintf('%s%i%s',results_filename1, k, figure_filename2);
    %     figure_axes=axes('Parent', figure_file);
    %     hold(figure_axes,'all');
    %     plot(xvar, powerMatrix(:,k), 'x-');
    %     hold on;
    %     plot(xvar, f(k,:),'r--');
    %     xlabel('$${i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}$$','interpreter','latex');
    %     ylabel('Power [W]');
    %     title(sprintf('Power distribution of HG_{%d}_0 mode',k-1));
    %     saveas(figure_file, sprintf('%s%s',fitting_path, figure_filename));     
    end
    
    
    %% Plots power distribution for higher-order HG-modes
    % HG_modes_plot(xvar,totalpower,maxTEM,powerMatrix);
    fitting_legend_string{L_itr}=num2str(L);
end

%% Plotting

% Plots power for each HG mode for different bs positions
power_distance_plot(maxTEM,L_to,L_from,L_step,xvar_L,power_L,fitting_legend_string);


% email_address='laura.sinkunaite@ligo-wa.caltech.edu';
% subject_message='Run complete!';
% message=sprintf('L_from=%f, L_to=%f, maxTEM=%d',L_from,L_to,maxTEM);
% email_address='laura.sinkunaite@ligo-wa.caltech.edu';
% files_to_send='%sfitting_HG*.txt';

% audio_announcement(); % Audio announcement
% email_result(fitting_path,L_from,L_to,maxTEM,code_path,email_address,subject_message,message,files_to_send); % Emails fitting results
