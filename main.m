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

maxTEM=5; % # of modes to be analysed: maxTEM+1
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

alphaITM0=0.0000001; %alphaETM0=0.0000003579;
alphaETM0=0;
alpha=(R_etm*alphaETM0*2+R_itm*alphaITM0*2)/((R_etm+R_itm-L)*alpha0);
k=(R_etm*alphaETM0*2-R_itm*alphaITM0*2)/(R_itm+R_etm-L);
a=((R_itm*alphaITM0*2)+(k*(R_etm-tL)))/w0; % a/w0
xvar=power((power(alpha,2) + power(a,2)),.5);

fitting_path='/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/';
fTABLE_filename='power_Table';
rTABLE_filename='ratio_Table';
results_filename2='.txt';
bash_filename2 = 'step1.sh';
% Relative ratios of power coeffic = abs | (a / w0) + i(alpha / alpha0) |
p=zeros((maxTEM+1), (poly_degree_plot+1));
TEMmatrix=zeros(theta_bin*theta_bin,((maxTEM+2)*(maxTEM+1)/2));
Table_Matrix=csvread(strcat(fitting_path,fTABLE_filename,results_filename2));
Ratio_Matrix=Ratio_Table(fitting_path,rTABLE_filename,results_filename2,Table_Matrix,bash_filename2);


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
if (length(pks))>1
    r=0;
    for pkr_iter=1:(length(pks)-1)
        pkr_el=pks(pkr_iter);
        loc_el=locs(pkr_iter);
        for pkr_iter2=(pkr_iter+1):length(pks)
            pkr_el2=pks(pkr_iter2);
            loc_el2=locs(pkr_iter2);
            r=r+1;
            pkr(r)=pkr_el2/pkr_el;
            locr(r)=loc_el2-loc_el;
        end
    end
end

z_R=(pi*(power(w0,2)))/lambda;
gouy_array=zeros(1,maxTEM+1);            
for gouy_iter=0:maxTEM
    gouy_array(gouy_iter+1)=(gouy_iter+1)*(atan(tL/z_R)-atan((L-tL)/z_R));
end

figure;
plot(xvar0, totalpower0, 'r-');
xlabel('ETM tuning [deg]');
ylabel('Power [W]');
title('Power distribution of different HG modes');

comparison_Value=0.01;
comparison_Index=0;
comparison_Index2=0;
% for pkr_Iter=1:length(pkr)
%     for RatioRow_Iter=1:size(Ratio_Matrix,1)
%         for RatioColumn_Iter=1:size(Ratio_Matrix,2)
%             if (abs(pkr(pkr_Iter)-Ratio_Matrix(RatioRow_Iter,RatioColumn_Iter)))<=(comparison_Value*(pkr(pkr_Iter)))
%                 comparison_Index=comparison_Index+1;
%                 Output(comparison_Index)=RatioRow_Iter;
%                 if pkr_Iter ~=length(pkr)
%                     fprintf('******************************************Proceeding\n');
%                     if (abs(pkr(pkr_Iter+1)-Ratio_Matrix(RatioRow_Iter,RatioColumn_Iter)))<=(comparison_Value*(pkr(pkr_Iter+1)))
%                         comparison_Index2=comparison_Index2+1;
%                         Output2(comparison_Index2)=RatioRow_Iter;
%                         fprintf('******************************************************Test: passed****\n');
%                     end
%                 end
%             end
%         end
%     end
% end
% for pkr_Iter=1:length(pkr)
%     Inter_Matrix=((abs(pkr(pkr_Iter))-Ratio_Matrix)<=(comparison_Value*(pkr(pkr_Iter))));
% end

Misalignment=[];
tol_Index=0.0006;
% for Ratio_Iter=1:(size(Ratio_Matrix,1))
%     if all(ismembertol(pkr,Ratio_Matrix(Ratio_Iter,:),tol_Index));
%         %Misalignment=[Misalignment Ratio_Matrix(Ratio_Iter,1)];
%         Misalignment=[Misalignment Ratio_Iter];
%     end
% end


for Ratio_Iter=1:(size(Ratio_Matrix,1))
    Empty_array=[];
    for index_pkr=1:length(pkr)
        for Ratio_Index=1:(size(Ratio_Matrix,1))
            for Column_Index=1:(size(Ratio_Matrix,2))
                for Pkr_Index=1:length(pkr)
                    if (Ratio_Matrix(Ratio_Index,Column_Index)-pkr(Pkr_Index)<=0.1)
                        Empty_array=[Empty_array (ismembertol(pkr(index_pkr),Ratio_Matrix(Ratio_Iter,:),tol_Index))];
                    end
                end
            end
        end
    end
    if all(Empty_array)
        Misalignment=[Misalignment Ratio_Iter];
        %Misalignment=[Misalignment (Ratio_Matrix(Ratio_Iter,1))];
    end
end

% comp_Value=1;
% for Ratio_Iter=1:(size(Ratio_Matrix,1))
%     for Column_Index=1:(size(Ratio_Matrix,2))
%         Empty_array=[];
%         for pkr_Index=1:length(pkr)
%             Empty_array=[Empty_array ((abs(pkr(pkr_Index)-Ratio_Matrix(Ratio_Iter,Column_Index)))<=(comp_Value*(pkr(pkr_Index))))];
%         end
%         if all(Empty_array)
%             Misalignment=[Misalignment Ratio_Iter];
%         end
%     end
% end
    