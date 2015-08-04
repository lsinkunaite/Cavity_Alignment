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
% Is_Unique(poly_degree_fit,theta_to0,((theta_to0-theta_from0)/(theta_bin-1)),maxTEM);

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
theta_from0=-0.00001; theta_to0=0.00001; theta_bin = 11;

alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
%TEMmatrix=zeros(theta_bin,theta_bin,((maxTEM+2)*(maxTEM+1)/2));
%TEMmatrix=zeros((power(theta_bin,2)),((maxTEM+1)*(maxTEM+1)/2));
TEMmatrix=zeros(power(theta_bin,2),((maxTEM+1)*(maxTEM+2)/2));
gouy_array=zeros(maxTEM+1,maxTEM+1);

% Divergence angle
alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));

% Misalignment angle
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

        %alpha(j) = alphaITM(j) * 2 / alpha0; % alpha/alpha0
        alphaITM(j)=alphaITM(j)*2;
        alphaETM(j_iter)=alphaETM(j_iter)*2;
        alpha(j,j_iter)=(R_etm*alphaETM(j_iter)+R_itm*alphaITM(j))/((R_etm+R_itm-L)*alpha0);
        k=(R_etm*alphaETM(j_iter)-R_itm*alphaITM(j))/(R_itm+R_etm-L);
        a(j,j_iter)=((R_itm*alphaITM(j))+(k*(R_etm-tL)))/w0; % a/w0
        %xvar(j,j_iter)=power((power(alpha(j,j_iter),2) + power(a(j,j_iter),2)),.5);
        xvar(((j-1)*theta_bin)+j_iter)=power((power(alpha(j,j_iter),2) + power(a(j,j_iter),2)),.5);
        
        %a(j) = alphaITM(j) * 2 * (L-tL) / w0; % a/w0
        %a(j,j_iter) = (alphaITM(j)*(L-tL)) + (alphaETM(j_iter)*tL);
        %xvar(j) = power((power(alpha(j),2) + power(a(j),2)),.5);
               
        
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
        %TEMmatrix(j,j_iter,:)=results(1, 3:end);
        TEMmatrix((j-1)*theta_bin+j_iter,:)=results(1,3:end);
    end
end


%% Fitting with a predefined-order polynomial

% Generates power matrix
powerMatrix=zeros(length(alphaITM),length(alphaETM),maxTEM+1);
%powerMatrix=zeros(length(alphaITM), maxTEM+1);
% for TEMorder=0:maxTEM
%     orderIndex=1+(TEMorder*(TEMorder+1)/2);
%     for jj=1:(TEMorder+1)
%         powerMatrix(:,TEMorder+1) = powerMatrix(:,TEMorder+1)+TEMmatrix(:,orderIndex+jj-1).^2;
%     end
% end

% for TEMorder=0:maxTEM
%     orderIndex=1+(TEMorder*(TEMorder+1)/2);
%     for jj=1:(TEMorder+1)
%         powerMatrix(:,:,TEMorder+1) = powerMatrix(:,:,TEMorder+1)+TEMmatrix(:,:,orderIndex+jj-1).^2;
%     end
% end
% totalpower=sum(powerMatrix, 2);


%xvar_reshaped=reshape(xvar,[],1);
dim_iter_tmp=size(TEMmatrix);
%TEMmatrix_reshaped=reshape(TEMmatrix,[],(dim_iter_tmp(length(dim_iter_tmp))));
for dim_iter=1:(dim_iter_tmp(length(dim_iter_tmp)))
    %plot(xvar_reshaped(:,dim_iter),TEMmatrix_reshaped(:,dim_iter));
    figure;
    plot(xvar(:,dim_iter),TEMmatrix(:,dim_iter));
    hold on;
end


%xlabel('{\alpha_{ITM}}');
%ylabel('{\alpha_{ETM}}');
%title('Power');

% results_filename1 = 'fit_results_';
% results_filename2 = '.txt';
% figure_filename2 = '.jpg';
% fFIT_filename = 'fit_match_';
% fFIT_All_filename = 'fitting_All_HG';
% fTABLE_filename = 'power_Table';
% fitting_path = '/home/laura/Finesse2.0/Misalignment/Fitting/';
% bash_filename1 = 'bash_test.sh';
% bash_filename2 = 'step1.sh';
% fRTABLE_filename = 'Rpower_Table';
% 
% fRTABLE=fopen(strcat(fitting_path,fRTABLE_filename,results_filename2),'w');
% fprintf(fRTABLE, ['m n ',xvar]);
% for m_Order=0:maxTEM
%     for n_Order=0:(m_Order)
%         Matrix_Index=((m_Order+1)*(m_Order+2)/2)-m_Order+n_Order;
%         fFIT_All=fopen(strcat(fitting_path,fFIT_All_filename,num2str(m_Order-n_Order),num2str(n_Order),results_filename2),'at');
%         fprintf(fRTABLE, [num2str(m_Order-n_Order), ' ',num2str(n_Order), ' ',num2str((TEMmatrix(:,Matrix_Index).^2)'),'\n']);
%     end
% end
% %LaTEX_Table(bash_filename2,strcat(fitting_path,fRTABLE_filename,results_filename2));
% fclose(fRTABLE);
% 
% % % Prints out amplitude [TEMmatrix] or power [powerMatrix] coefficient table
% % % Coeff_Table(strcat(fitting_path,fTABLE_filename,results_filename2),xvar,powerMatrix,strcat(fitting_path,fTABLE_filename,results_filename2),bash_filename2);
% % 
% % for k=1:(length(powerMatrix(1,:)))
% %     p(k,:)=polyfit(xvar',powerMatrix(:,k),poly_degree_plot);
% %     fFIT=fopen(sprintf('%s%s%i%s',fitting_path,fFIT_filename,k,results_filename2), 'w');
% %     for l=1:(length(poly_degree_array))
% %         % Prints fitting results to a text file
% %         fprintf(fFIT, [num2str(polyfit(xvar',powerMatrix(:,k),poly_degree_array(l))) '\n']);
% %     end
% %     fclose(fFIT);
% % 
% %     % Writes fitting data into separate files for each polynomial
% %     fFIT_mode=fopen(sprintf('%sfitting_HG%i0.txt',fitting_path,k-1),'at');
% %     fprintf(fFIT_mode, [num2str(L), ' ',num2str(polyfit(xvar',powerMatrix(:,k),poly_degree_array(length(poly_degree_array)))) '\n']);
% %     fclose(fFIT_mode);
% % 
% %     
% %     % Plots the power and poly-fit for each HG-mode
% %     power_fit_plot(results_filename1,figure_filename2,fitting_path,k,powerMatrix,xvar,f);
% % end
% % 
% % 
% % %% Plots power distribution for higher-order HG-modes
% HG_modes_plot(xvar,totalpower,maxTEM,powerMatrix);
% HG_modes_turbo_plot(xvar,totalpower,maxTEM,(TEMmatrix.^2));
%  
%     
%      
% % % % email_address='laura.sinkunaite@ligo-wa.caltech.edu';
% % % % subject_message='Run complete!';
% % % % message=sprintf('L_from=%f, L_to=%f, maxTEM=%d',L_from,L_to,maxTEM);
% % % % email_address='laura.sinkunaite@ligo-wa.caltech.edu';
% % % % files_to_send='%sfitting_HG*.txt';
% % % 
% % % % audio_announcement(); % Audio announcement
% % % % email_result(fitting_path,L_from,L_to,maxTEM,code_path,email_address,subject_message,message,files_to_send); % Emails fitting results
