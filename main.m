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
delete_old(maxTEM,old_filename);
delete_old(maxTEM,old_filename2);
delete('/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/ratio_Table.txt');

% Tilting angle theta
%theta_from0=-0.00001; theta_to0=0.00001; theta_bin = 11;
theta_from0=0; theta_to0=0.00001; theta_bin=11;

alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin*theta_bin,((maxTEM+2)*(maxTEM+1)/2));

alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));


theta_constant=power((1+(power((alpha0/w0),2))*(power(L,2)-(2*L*tL)+power(tL,2))),(.5)); 
theta_to=theta_to0/theta_constant; theta_from=theta_from0;
theta_step=(theta_to-theta_from)/(theta_bin-1);
alphaITM = (theta_from:theta_step:theta_to);
alphaETM = (theta_from:theta_step:theta_to);

alphaITM0=0.000000854; alphaETM0=0.000002401;
%alphaITM0=1e-6;alphaETM0=5e-7;
alpha=(R_etm*alphaETM0+R_itm*alphaITM0)/((R_etm+R_itm-L)*alpha0);
%k=(R_etm*alphaETM0-R_itm*alphaITM0)/(R_itm+R_etm-L);
%a=((R_itm*alphaITM0)+(k*(R_etm-tL)))/w0; % a/w0
a=((R_etm-tL)*(R_itm*alphaITM0)-(tL-L+R_itm)*(R_etm*alphaETM0))/((R_itm+R_etm-L)*w0);
xvar=power((power(alpha,2) + power(a,2)),.5);

fitting_path='/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/';
fTABLE_filename='power_Table';
rTABLE_filename='ratio_Table';
results_filename2='.txt';
bash_filename2 = 'step1.sh';
% Relative ratios of power coeffic = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin*theta_bin,((maxTEM+2)*(maxTEM+1)/2));


fID=fopen(strcat(code_path,finesse_filename,'kat.txt'), 'w');
fprintf(fID, 's sarm %f n1 n2\n', L);
fprintf(fID, 'attr itm Rc %f\n', R_itm);
fprintf(fID, 'attr etm Rc %f\n', -R_etm);
fprintf(fID, 'attr itm xbeta %.12f\n', alphaITM0);
fprintf(fID, 'attr etm xbeta %.12f\n', alphaETM0);
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

% Sorts peaks in a descending order, gives their locations in degrees
[L2R_pkr,L2R_locs] = LeftToRight(pkr,locs);
[R2L_pkr,R2L_locs] = RightToLeft(pkr,locs);


Table_Matrix=csvread(strcat(fitting_path,fTABLE_filename,results_filename2));
Ratio_Matrix=Ratio_Table(pkr,fitting_path,rTABLE_filename,results_filename2,Table_Matrix,bash_filename2);

z_R=(pi*(power(w0,2)))/lambda;
gouy_array=zeros(1,maxTEM+1);            
for gouy_iter=0:maxTEM
    % Gouy phase shift in radians
    gouy_array(gouy_iter+1)=(gouy_iter+1)*(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi;
end
gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi;


[L2R_pkr_gouy,L2R_locs_gouy]=Gouy_Left2Right(pkr,locs,gouy_shift);
[R2L_pkr_gouy,R2L_locs_gouy]=Gouy_Right2Left(pkr,locs,gouy_shift);


[pkr_gouy,locs_gouy]=Gouy_Sort(pkr,locs,gouy_shift);


% [max_pk,max_loc]=max(pkr);
% gouy_peaks(1)=max_pk;
% tol=15;
% for i=2:length(locs)
%     if (max_loc+gouy_shift)>180
%         idx=find(abs(locs(i)-(max_loc+gouy_shift-180))<tol);
%         gouy_peaks(i)=pkr(idx);
%     else
%         idx=find(abs(locs(i)-(max_loc+gouy_shift))<tol);
%         gouy_peaks(i)=pkr(idx);
%     end
% end
    

figure;
plot(xvar0, totalpower0, 'r-');
xlabel('ETM tuning [deg]');
ylabel('Power [W]');
title('Power distribution of different HG modes');

% Calculates misalignment
[Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,pkr_gouy,locs_gouy);
Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1);


[c, index]= min(abs(Ratio_Matrix(:,1)-xvar));
Ratio_Matrix(index,:)
pkr_gouy
Ratio_Matrix(Row_Gouy,:)

fprintf('Misalignment: calculated = %f, Gouy algorithm = %f\n',xvar,Mis_Par_Gouy);
fprintf('Row number = %d, mode number = %d\n',Row_Gouy,Mode_Gouy);

Check_Transmittance(Ratio_Matrix,index,gouy_shift);