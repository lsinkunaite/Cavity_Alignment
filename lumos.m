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

maxTEM=1; % # of modes to be analysed: maxTEM+1
poly_degree_plot=8; % Degree of polynomial fit for plotting
poly_degree_fit=10; % Degree of polynomial fit for calculations

% Even-mode-only fitting
poly_degree_array=linspace(0,(poly_degree_fit-mod(poly_degree_fit,2)),((poly_degree_fit-mod(poly_degree_fit,2))/2)+1);

tL = 2158.28; % Distance to the beam waist
L = 4000.00; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
R_itm = 1939.3;

% Deleting old files
old_filename = 'Fitting/fitting_HG%s%s.txt';
old_filename2 = 'Fitting/fitting_All_HG%s%s.txt';
delete('Fitting/power_Table.txt');
delete_old(maxTEM,old_filename);
delete_old(maxTEM,old_filename2);

% Tilting angle theta
%theta_from0=-0.00001; theta_to0=0.00001; theta_bin = 11;
theta_from0=0; theta_to0=0.00001; theta_bin=11;

alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin*theta_bin,((maxTEM+2)*(maxTEM+1)/2));
gouy_array=zeros(maxTEM+1,maxTEM+1);

alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));

theta_constant=power((1+(power((alpha0/w0),2))*(power(L,2)-(2*L*tL)+power(tL,2))),(.5)); 
theta_to=theta_to0/theta_constant; theta_from=theta_from0;
theta_step=(theta_to-theta_from)/(theta_bin-1);
alphaITM = (theta_from:theta_step:theta_to);
alphaETM = (theta_from:theta_step:theta_to);

%% Adds higher-order TEM modes to Finesse script    
for j = 1:length(alphaITM)
    for j_iter = 1:length(alphaETM)
        fID=fopen(strcat(finesse_filename,'kat.txt'), 'w');
        fprintf(fID, 's sarm %f n1 n2\n', L);
        fprintf(fID, 'attr itm Rc %f\n', R_itm);
        fprintf(fID, 'attr etm Rc %f\n', -R_etm);
        fprintf(fID, 'attr itm xbeta %.12f\n', alphaITM(j));
        fprintf(fID, 'attr etm xbeta %.12f\n', alphaETM(j_iter));
        fprintf(fID, 'maxtem %d\n', maxTEM);      

        alpha(j)=(alphaITM(j)*2*R_itm)+(alphaETM(j_iter)*2*R_etm)/((R_etm+R_itm-L)*alpha0); % alpha/alpha0
        k=(R_etm*alphaETM(j_iter)-R_itm*alphaITM(j))/(R_itm+R_etm-L);
        a(j)=((alphaITM(j)*2*R_itm)+(k*(R_etm-tL)))/w0; % a/w0
        xvar((j-1)*theta_bin+j_iter)=power((power(alpha(j),2)+power(a(j),2)),.5);


        % Generates HG mode
        for ii=0:maxTEM
            for ll=0:ii
                fprintf(fID, ['ad ad' int2str(ii-ll) int2str(ll) ' ' int2str(ii-ll) ' ' int2str(ll) ' 0 n3\n']);
                gouy_array(ii-ll+1,ll+1)=(ii+1)*atan(lambda*L/(pi*power(w0,2)));
            end
        end

        fclose(fID);

        system(sprintf('cat %s.kat %skat.txt > %sout.kat', finesse_filename, finesse_filename, finesse_filename));
        system(sprintf('%s %sout', finesse_filepath, finesse_filename));
        results=load(strcat(finesse_filename,'out.out'));
        TEMmatrix((j-1)*theta_bin+j_iter, :)=results(1, 3:end); 
    end
end 
    
%% Fitting with a predefined-order polynomial

% Generates power matrix
powerMatrix=zeros(length(TEMmatrix), maxTEM+1);
for TEMorder=0:maxTEM
    orderIndex=1+(TEMorder*(TEMorder+1)/2);
    for jj=1:(TEMorder+1)
        powerMatrix(:,TEMorder+1) = powerMatrix(:,TEMorder+1)+TEMmatrix(:,orderIndex+jj-1).^2;
    end
end
totalpower=sum(powerMatrix, 2);

% dim_iter_tmp=size(TEMmatrix);
% for dim_iter=1:(dim_iter_tmp(length(dim_iter_tmp)))
%     figure;
%     plot(xvar(1,:),TEMmatrix(:,dim_iter));
%     hold on;
% end

figure;
plot(xvar, totalpower, 'r-');
hold on;
legend_string={'total'};
for ii=1:((maxTEM+1)*(maxTEM+2)/2)
    plot(xvar,(TEMmatrix(:, ii).^2),'x-');
    xlabel('$$\Big|{i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}\Big|$$','interpreter','latex');
    ylabel('Power [W]');
    title('Power distribution of different HG modes');
    legend_string{ii+1}=num2str(ii-1);
end
set(legend(cellstr(strcat('HG = ',legend_string))), 'location', 'NorthEastOutside');
    
% results_filename1 = 'fit_results_';
% results_filename2 = '.txt';
% figure_filename2 = '.jpg';
% fFIT_filename = 'fit_match_';
% fFIT_All_filename = 'fitting_All_HG';
% fTABLE_filename = 'power_Table';
% fitting_path = '/home/laura/Finesse2.0/Misalignment/Fitting/';
% bash_filename1 = 'bash_test.sh';
% bash_filename2 = 'step1.sh';
% %     
% % for m_Order=0:maxTEM
% %     for n_Order=0:(m_Order)
% %         Matrix_Index=((m_Order+1)*(m_Order+2)/2)-m_Order+n_Order;
% %         fFIT_All=fopen(strcat(fitting_path,fFIT_All_filename,num2str(m_Order-n_Order),num2str(n_Order),results_filename2),'at');
% %         % Writes fitting data into separate files for each polynomial
% %         fprintf(fFIT_All, [num2str(L), ' ',num2str(polyfit(xvar',TEMmatrix(:,Matrix_Index),poly_degree_array(length(poly_degree_array)))) '\n']);
% %         fclose(fFIT_All);
% %         %LaTEX_Table(bash_filename1,strcat(fitting_path,fFIT_All_filename,'*',results_filename2));
% %         if (L == L_to)
% %             LaTEX_Table(bash_filename2,strcat(fitting_path,fFIT_All_filename,num2str(m_Order-n_Order),num2str(n_Order),results_filename2));
% %         end
% %     end
% % end
%     
% % Prints out amplitude [TEMmatrix] or power [powerMatrix] coefficient table
% % Coeff_Table(strcat(fitting_path,fTABLE_filename,results_filename2),xvar,powerMatrix,strcat(fitting_path,fTABLE_filename,results_filename2),bash_filename2);
%     
% for k=1:(length(powerMatrix(1,:)))
%     p(k,:)=polyfit(xvar',powerMatrix(:,k),poly_degree_plot);
%     fFIT=fopen(sprintf('%s%s%i%s',fitting_path,fFIT_filename,k,results_filename2), 'w');
%     for l=1:(length(poly_degree_array))
%         % Prints fitting results to a text file
%         fprintf(fFIT, [num2str(polyfit(xvar',powerMatrix(:,k),poly_degree_array(l))) '\n']);
%     end
%     fclose(fFIT);
% 
%     % Writes fitting data into separate files for each polynomial
%     fFIT_mode=fopen(sprintf('%sfitting_HG%i0.txt',fitting_path,k-1),'at');
%     fprintf(fFIT_mode, [num2str(L), ' ',num2str(polyfit(xvar',powerMatrix(:,k),poly_degree_array(length(poly_degree_array)))) '\n']);
%     fclose(fFIT_mode);
% 
%     % Tests goodness-of-fit
%     %     f(k,:)=polyval(p(k,:),xvar');
%     %     T = table(xvar',powerMatrix(:,k),(f(k,:))',(powerMatrix(:,k)-(f(k,:))'),'VariableNames',{'X','Y','Fit','FitError'});
%     %     results_filename = sprintf('%s%s%i%s',fitting_path, results_filename1, k, results_filename2);
%     %     writetable(T,results_filename,'Delimiter',' ');
% 
%         xvar_L((k+(maxTEM+1)*(L_itr-1)),:)=xvar;
%         power_L(:,(k+(maxTEM+1)*(L_itr-1)))=powerMatrix(:,k);
% 
%         % Plots the power and poly-fit for each HG-mode
%         % power_fit_plot(results_filename1,figure_filename2,fitting_path,k,powerMatrix,xvar,f);
%     end
% 
% 
%     %% Plots power distribution for higher-order HG-modes
%     % HG_modes_plot(xvar,totalpower,maxTEM,powerMatrix);
%     fitting_legend_string{L_itr}=num2str(L);
% end
% 
% %% Plotting
% 
% % Plots power for each HG mode for different mirror positions
% power_distance_plot(maxTEM,L_to,L_from,L_step,xvar_L,power_L,fitting_legend_string);
% 
