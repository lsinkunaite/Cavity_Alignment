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
L = 3000.00; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
%R_itm = 1939.3;

% Deleting old files
old_filename = 'Fitting/fitting_HG%s%s.txt';
old_filename2 = 'Fitting/fitting_All_HG%s%s.txt';
delete_old(maxTEM,old_filename);
delete_old(maxTEM,old_filename2);

% Tilting angle theta
theta_from0=0; theta_to0=0.00001; theta_bin = 51;

alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin,((maxTEM+2)*(maxTEM+1)/2));

% Distance to the mirror
L_bin=4;
%L_from=2200.00; L_to=12200.00; L_step=1000.00;
L_from=tL; L_to=24400.00; L_step=(L_to-L_from)/L_bin;
xvar_L=zeros((((L_to-L_from)/L_step)+1)*(maxTEM+1), theta_bin);
power_L=zeros(theta_bin,(((L_to-L_from)/L_step)+1)*(maxTEM+1));

L_itr = 0;
for L = L_from:L_step:L_to
    L_itr = L_itr+1;

    % Radius of curvature of mirror
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
            for ll=0:ii
                fprintf(fID, ['ad ad' int2str(ii-ll) int2str(ll) ' ' int2str(ii-ll) ' ' int2str(ll) ' 0 n1\n']);
            end
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
        orderIndex=1+(TEMorder*(TEMorder+1)/2);
        for jj=1:(TEMorder+1)
            powerMatrix(:,TEMorder+1) = powerMatrix(:,TEMorder+1)+TEMmatrix(:,orderIndex+jj-1).^2;
        end
    end
    totalpower=sum(powerMatrix, 2);

    results_filename1 = 'fit_results_';
    results_filename2 = '.txt';
    figure_filename2 = '.jpg';
    fFIT_filename = 'fit_match_';
    fFIT_All_filename = 'fitting_All_HG';
    fitting_path = '/home/laura/Finesse2.0/Misalignment/Fitting/';
    
    for m_Order=0:maxTEM
        for n_Order=0:(m_Order)
            Matrix_Index=((m_Order+1)*(m_Order+2)/2)-m_Order+n_Order;
            fFIT_All=fopen(strcat(fitting_path,fFIT_All_filename,num2str(m_Order-n_Order),num2str(n_Order),results_filename2),'at');
            % Writes fitting data into separate files for each polynomial
            fprintf(fFIT_All, [num2str(L), ' ',num2str(polyfit(xvar',TEMmatrix(:,Matrix_Index),poly_degree_array(length(poly_degree_array)))) '\n']);
            fclose(fFIT_All);
            %system(['./bash_test.sh ' strcat(fitting_path,fFIT_All_filename,'*',results_filename2)]);
            if (L == L_to)
                system(['./step1.sh ' strcat(fitting_path,fFIT_All_filename,num2str(m_Order-n_Order),num2str(n_Order),results_filename2)]);
            end
        end
    end
    
    
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

        xvar_L((k+(maxTEM+1)*(L_itr-1)),:)=xvar;
        power_L(:,(k+(maxTEM+1)*(L_itr-1)))=powerMatrix(:,k);

        % Plots the power and poly-fit for each HG-mode
        % power_fit_plot(results_filename1,figure_filename2,fitting_path,k,powerMatrix,xvar,f);
    end


    %% Plots power distribution for higher-order HG-modes
    % HG_modes_plot(xvar,totalpower,maxTEM,powerMatrix);
    fitting_legend_string{L_itr}=num2str(L);
end

%% Plotting

% Plots power for each HG mode for different mirror positions
power_distance_plot(maxTEM,L_to,L_from,L_step,xvar_L,power_L,fitting_legend_string);


% email_address='laura.sinkunaite@ligo-wa.caltech.edu';
% subject_message='Run complete!';
% message=sprintf('L_from=%f, L_to=%f, maxTEM=%d',L_from,L_to,maxTEM);
% email_address='laura.sinkunaite@ligo-wa.caltech.edu';
% files_to_send='%sfitting_HG*.txt';

% audio_announcement(); % Audio announcement
% email_result(fitting_path,L_from,L_to,maxTEM,code_path,email_address,subject_message,message,files_to_send); % Emails fitting results
