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

finesse_filename='freise2'; % Finesse filename w/o extension
finesse_filepath='/home/laurasinkunaite/Finesse2.0/Misalignment/kat'; % Path to kat.ini
code_path='/home/laurasinkunaite/Finesse2.0/Misalignment/';

maxTEM=20; % # of modes to be analysed: maxTEM+1

tL = 2158.28; % Distance to the beam waist
L = 4000.00; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
R_itm = 1939.3;

% Tilting angle theta
theta_from0=0; theta_to0=0.00001; theta_bin=11;

alpha_P=[]; % 2*theta / alpha0
alpha_Y=[];
a_P=[]; % Transverse displacement
a_Y=[];
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
TEMmatrix=zeros(theta_bin*theta_bin,((maxTEM+2)*(maxTEM+1)/2));
alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));

theta_constant=power((1+(power((alpha0/w0),2))*(power(L,2)-(2*L*tL)+power(tL,2))),(.5)); 
theta_to=theta_to0/theta_constant; theta_from=theta_from0;
theta_step=(theta_to-theta_from)/(theta_bin-1);
alphaITM = (theta_from:theta_step:theta_to);
alphaETM = (theta_from:theta_step:theta_to);

alphaETM_P=-1.55e-6; alphaETM_Y=1.35e-6;
%alphaITM_P=8.5e-7; alphaITM_Y=1.6e-6;
alphaITM_P=alphaETM_P*(-R_etm/R_itm);
alphaITM_Y=alphaETM_Y*(R_etm/R_itm)*(tL-L+R_itm)/(R_etm-tL);

alpha_P=(R_etm*alphaETM_P+R_itm*alphaITM_P)/((R_etm+R_itm-L)*alpha0);
alpha_Y=(R_etm*alphaETM_Y+R_itm*alphaITM_Y)/((R_etm+R_itm-L)*alpha0);
a_P=((R_etm-tL)*(R_itm*alphaITM_P)-(tL-L+R_itm)*(R_etm*alphaETM_P))/((R_itm+R_etm-L)*w0);
a_Y=((R_etm-tL)*(R_itm*alphaITM_Y)-(tL-L+R_itm)*(R_etm*alphaETM_Y))/((R_itm+R_etm-L)*w0);
xvar= power(((power(alpha_P,2)+power(alpha_Y,2))+(power(a_P,2)+power(a_Y,2))),.5);

fitting_path='/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/';
fTABLE_filename='power_Table';
rTABLE_filename='ratio_Table';
results_filename2='.txt';
bash_filename2 = 'step1.sh';
% Relative ratios of power coeffic = abs | (a / w0) + i(alpha / alpha0) |
TEMmatrix=zeros(theta_bin*theta_bin,((maxTEM+2)*(maxTEM+1)/2));


fID=fopen(strcat(code_path,finesse_filename,'kat.txt'), 'w');
fprintf(fID, 's sarm %f n1 n2\n', L);
fprintf(fID, 'attr itm Rc %f\n', R_itm);
fprintf(fID, 'attr etm Rc %f\n', -R_etm);
fprintf(fID, 'attr itm xbeta %.12f\n', alphaITM_P);
fprintf(fID, 'attr etm xbeta %.12f\n', alphaETM_P);
fprintf(fID, 'attr itm ybeta %.12f\n', alphaITM_Y);
fprintf(fID, 'attr etm ybeta %.12f\n', alphaETM_Y);
fprintf(fID, 'maxtem %d\n', maxTEM);
fclose(fID); % = abs | (a / w0) + i(alpha / alpha0) |

system(sprintf('cat %s.kat %skat.txt > %sout.kat', finesse_filename, finesse_filename, finesse_filename));
system(sprintf('%s %sout', finesse_filepath, finesse_filename));
results=load(strcat(finesse_filename,'out.out'));
xvar0(:,1)=results(1:end,1);
totalpower0(:,1)=results(1:end,2);
[pks,locs]=findAllpeaks(results(:,2)');
for pkr_iter=1:(length(pks))
    ref_peak=max(pks);
    pkr(pkr_iter)=(pks(pkr_iter))/ref_peak;
end

Ratio_Matrix=csvread(strcat(fitting_path,rTABLE_filename,results_filename2));

z_R=(pi*(power(w0,2)))/lambda; % Rayleigh range
gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi; % Gouy phase shift


figure;
plot(xvar0, totalpower0, 'r-');
xlabel('ETM tuning [deg]');
ylabel('Power [W]');
title('Power distribution of different HG modes');

% Sorts peaks in an ascending order, gives their locations in degrees
[pkr_gouy,locs_gouy]=Gouy_Sort(pkr,locs,gouy_shift);

% Calculates misalignment
[Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,pkr_gouy);
Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1);

[c, index]= min(abs(Ratio_Matrix(:,1)-xvar));
Ratio_Matrix(index,:)
pkr_gouy
Ratio_Matrix(Row_Gouy,:)

fprintf('Misalignment: calculated = %f, Gouy algorithm = %f\n',xvar,Mis_Par_Gouy);
fprintf('Row number = %d, mode number = %d\n',Row_Gouy,Mode_Gouy);

Check_Transmittance(Ratio_Matrix,index,gouy_shift);