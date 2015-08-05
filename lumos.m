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

maxTEM=10; % # of modes to be analysed: maxTEM+1
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
%delete('Fitting/power_Table.txt');
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

alphaITM0=0.000002242394; alphaETM0=0.0000003579;
fID=fopen(strcat(finesse_filename,'kat.txt'), 'w');
fprintf(fID, 's sarm %f n1 n2\n', L);
fprintf(fID, 'attr itm Rc %f\n', R_itm);
fprintf(fID, 'attr etm Rc %f\n', -R_etm);
fprintf(fID, 'attr itm xbeta %.12f\n', alphaITM0);
fprintf(fID, 'attr etm xbeta %.12f\n', alphaETM0);
fprintf(fID, 'maxtem %d\n', maxTEM);

fclose(fID);
system(sprintf('cat %s.kat %skat.txt > %sout.kat', finesse_filename, finesse_filename, finesse_filename));
system(sprintf('%s %sout', finesse_filepath, finesse_filename));
results=load(strcat(finesse_filename,'out.out'));
TEMmatrix0(:, :)=results(1:end, 3:end); 
xvar0(:,1)=results(1:end,1);
totalpower0(:,1)=results(1:end,2);

figure;
plot(xvar0, totalpower0, 'r-');
hold on;
for ii=1:((maxTEM+1)*(maxTEM+2)/2)
    plot(xvar0,(TEMmatrix0(:, ii).^2),'x-');
    xlabel('ETM tuning [deg]');
    ylabel('Power [W]');
    title('Power distribution of different HG modes');
end
