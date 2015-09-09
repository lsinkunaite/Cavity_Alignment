
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                  %
%        HG mode decomposition coefficients        %
%                                                  %
%  main.m: runs Finesse file and varies the angle  %
%  of misalignment of the mirror. Calculates the   %
%  power of each mode up to maxTEM+1 and prints    %
%  out the fitting coefficients in tabular form.   %
%                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

finesse_filename='finesse_simulation'; % Finesse filename w/o extension
finesse_filepath='/home/laurasinkunaite/Finesse2.0/Project/Step1_Simulation/kat'; % Path to kat.ini
code_path='/home/laurasinkunaite/Finesse2.0/Project/Step1_Simulation/';

% Tilt angle
theta_from=0; theta_to=0.00001; theta_step=0.000001;

maxTEM=5; % # of modes to be analysed: maxTEM+1
tL = 2158.28; % Distance to the beam waist
lambda = 532e-09; % Wavelength
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54; % Radius of curvature of ETM (R=0,T=1), needed for divergence calculation
R_itm = 99999999999; % Radius of curvature for the flat-mirror case
L=2158.28; % Position of the mirror along the z-axis

%results_filename1 = 'fit_results_';
results_filename2 = '.txt';
figure_filename2 = '.jpg';
fFIT_filename = 'fit_match_';
%fFIT_All_filename = 'fitting_All_HG';
fTABLE_filename = 'power_Table';
rTABLE_filename = 'ratio_Table';
output_path = '/home/laurasinkunaite/Finesse2.0/Project/Step1_Simulation/Output/';
bash_filename = 'main.sh';

% Deleting old files
delete('Fitting/power_Table.txt');
delete(strcat(output_path,rTABLE_filename,results_filename2));

% Tilting mirror through angle theta
theta_from0=0; theta_to0=0.00007; theta_bin = 250;

% Misalignment angle alpha
alpha=[]; % 2*theta / alpha0
a=[]; % Beam waist radius
xvar=[]; % xvar = abs | (a / w0) + i(alpha / alpha0) |
%p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin,((maxTEM+2)*(maxTEM+1)/2));

% Divergence angle
alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));

% Normalisation constant for misalignment parameter when mirror is moved
% along the z-axis
theta_constant=power((1+(power((alpha0/w0),2))*(power(L,2)-(2*L*tL)+power(tL,2))),(.5)); 
theta_to=theta_to0/theta_constant; theta_from=theta_from0;
theta_step=(theta_to-theta_from)/(theta_bin-1);
alphaITM = (theta_from:theta_step:theta_to);


%% Adds higher-order TEM modes to Finesse script    
for j = 1:length(alphaITM)
    fID=fopen(strcat(finesse_filename,'kat.txt'), 'w');
    fprintf(fID, 's sarm %f n0 n1\n', L);
    fprintf(fID, 'attr mirror Rc %f\n', R_itm);
    fprintf(fID, 'attr mirror xbeta %.12f\n', alphaITM(j));
    fprintf(fID, 'maxtem %d\n', maxTEM);      

    alpha(j) = alphaITM(j) * 2 / alpha0; % alpha/alpha0
    a(j) = alphaITM(j) * 2 * (L-tL) / w0; % a/w0
    xvar(j) = power((power(alpha(j),2) + power(a(j),2)),.5); % normalised misalignment parameter


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

% Generates power matrix and consolidates same order modes (01+10=1,
% 21+12+30+03=3, etc)
powerMatrix=zeros(length(alphaITM), maxTEM+1);
for TEMorder=0:maxTEM
    orderIndex=1+(TEMorder*(TEMorder+1)/2);
    for jj=1:(TEMorder+1)
        powerMatrix(:,TEMorder+1) = powerMatrix(:,TEMorder+1)+TEMmatrix(:,orderIndex+jj-1).^2;
    end
end
totalpower=sum(powerMatrix, 2);

%% Mode decomposition plots
% figure3=figure;
% plot(xvar, totalpower, 'r-');
% hold on
% legend_order = linspace(0,maxTEM,maxTEM+1);
% legend_string={'total'};
% for ii=1:(maxTEM+1)
%     plot(xvar, powerMatrix(:, ii), 'x-');
%     xlim([theta_from (theta_to*1e05)]);
%     xlabel('$$\Big|{i}\frac{\alpha}{\alpha_0} + \frac{a}{w_0}\Big|$$','interpreter','latex');
%     ylabel('Power [W]');
%     title('Power distribution of different HG modes');
%     legend_string{ii+1}=num2str(ii-1);
% end
% set(legend(cellstr(strcat('HG_{',legend_string,'}_0'))), 'location', 'NorthEastOutside');
% saveas(figure3,strcat(code_path,'Output/power_all.epsc'));
% saveas(figure3,strcat(code_path,'Output/power_all.jpg'));
% saveas(figure3,strcat(code_path,'Output/power_all.fig'));
% saveas(figure3,strcat(code_path,'Output/power_all.pdf'));


% Generates a table with decomposition coefficients
Coeff_Table(strcat(output_path,fTABLE_filename,results_filename2),xvar,powerMatrix,strcat(output_path,fTABLE_filename,results_filename2),bash_filename);
Table_Matrix=csvread(strcat(output_path,fTABLE_filename,results_filename2));
% Ratios of modal decomposition coefficients
Ratio_Table(output_path,rTABLE_filename,results_filename2,Table_Matrix,bash_filename);
