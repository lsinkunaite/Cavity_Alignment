
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
finesse_filepath='/home/laurasinkunaite/Finesse2.0/Misalignment/kat'; % Path to kat.ini
code_path='/home/laurasinkunaite/Finesse2.0/Misalignment/';

maxTEM=5; % # of modes to be analysed: maxTEM+1
poly_degree_plot=8; % Degree of polynomial fit for plotting
poly_degree_fit=10; % Degree of polynomial fit for calculations

% Even-mode-only fitting
poly_degree_array=linspace(0,(poly_degree_fit-mod(poly_degree_fit,2)),((poly_degree_fit-mod(poly_degree_fit,2))/2)+1);

tL = 2158.28; % Distance to the beam waist
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
R_itm = 99999999999;
L=2158.28;

% Deleting old files
old_filename = 'Fitting/fitting_HG%s%s.txt';
old_filename2 = 'Fitting/fitting_All_HG%s%s.txt';
delete('Fitting/power_Table.txt');
delete_old(maxTEM,old_filename);
delete_old(maxTEM,old_filename2);

% Tilting angle theta
theta_from0=0; theta_to0=0.00005; theta_bin = 1000;

alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin,((maxTEM+2)*(maxTEM+1)/2));

% Divergence angle
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
fTABLE_filename = 'power_Table';
fitting_path = '/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/';
bash_filename1 = 'bash_test.sh';
bash_filename2 = 'step1.sh';


Coeff_Table(strcat(fitting_path,fTABLE_filename,results_filename2),xvar,powerMatrix,strcat(fitting_path,fTABLE_filename,results_filename2),bash_filename2);