%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
%                   Automation                      %
%                                                   %
%  main.m: reads in measured data, applies various  %
%  statistical techniques to handle it, and returns %
%  the estimated misalignment parameter.            %
%                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; 
clear all;

%data_path='/home/laurasinkunaite/Finesse2.0/Project/Step3_Automation/laura_measurements/';
data_path='C:\Users\user\Desktop\Finesse2.0\Project\Step3_Automation\laura_measurements\';
data_name_16k='x-arm_%sline_16k.txt';
data_name_256='x-arm_%sline_256.txt';
%Ratio_Matrix=csvread('/home/laurasinkunaite/Finesse2.0/Project/Step1_Simulation/Output/ratio_Table.txt');
Ratio_Matrix=csvread('C:\Users\user\Desktop\Finesse2.0\Project\Step1_Simulation\Output\ratio_Table.txt');

tL = 2158.28; % Distance to the beam waist
L = 4000.00; % Cavity length
lambda = 532e-09; % Green light
w0 = 8.47e-03; % Beam waist radius
z_R=(pi*(power(w0,2)))/lambda; % Rayleigh range

% Low-pass Butterworth filter
[z,p,k] = butter(5,0.4,'low');
sos = zp2sos(z,p,k);
% Uncomment for a filter plot
% fvtool(sos,'Analysis','freq')

% True misalignment values
test_array=[0 0.687242 0.903745 0.747380 6.405156 1.130984 0.945770];

Data_N=7; % Number of datafiles
% Iterates over measured data (i = 7)
for i=1:Data_N
    %Input_Matrix_16k=csvread(strcat(data_path,sprintf(data_name_16k,num2str(i))));
    %Input_Matrix_256=csvread(strcat(data_path,sprintf(data_name_256,num2str(i))));
    Input_Matrix_16k=load(strcat(data_path,sprintf(data_name_16k,num2str(i))));
    Input_Matrix_256=load(strcat(data_path,sprintf(data_name_256,num2str(i))));
    Optical_Lever=Input_Matrix_256(:,3)+Input_Matrix_256(:,4)+Input_Matrix_256(:,6)+Input_Matrix_256(:,7);
    test_value=test_array(i);
    
    % Downsamples 16k matrix
    Input_Matrix_16k=Decimator(Input_Matrix_16k,8);
    % Low-pass filter
    Input_Matrix_16k=sosfilt(sos,Input_Matrix_16k);
        
    % Anti-resolution and anti-spike parameters
    antires=10;antispike=.01;
    
    % Ratio between domains
    Domain_factor=(length(Input_Matrix_16k(:,2)))/(length(Input_Matrix_256(:,2)));
    
    % Interpolation
    x=1:1:(length(Input_Matrix_256(:,2))); % Old domain 
    x_in=x*Domain_factor;
    x_out=1:1:(length(Input_Matrix_16k(:,2))); % New domain
    witness=Input_Matrix_256(:,2)+Input_Matrix_256(:,5);
    Interpolated_witness=Interpolator(x_in,x_out,witness); % Interpolated witness-sensor data
    Interpolated_ol=Interpolator(x_in,x_out,Optical_Lever); % Interpolated optical-lever data
    
    maxTEM=5; % Number of TEM modes to be analysed
    mode_algo=maxTEM+1;
    [pks,locs]=findpeaks(Input_Matrix_16k(:,2)');
    % Finds boundaries for region selection
    [Domain_From,Domain_To]=Extreme(Input_Matrix_16k(:,2),Interpolated_witness,pks,locs,0.2);
    [True_pks,True_locs]=findTruepeaks(Input_Matrix_16k(Domain_From:Domain_To,2)',antires,antispike);
    
    %% Uncomment for witness sensor and optical lever plot
%     figure();
%     subplot(2,1,1);
%     plot(Interpolated_ol);
%     hold on;
%     plot(Domain_From,Interpolated_ol(Domain_From),'ok');
%     plot(Domain_To,Interpolated_ol(Domain_To),'or');
%     title('Optical Lever');
%     ylabel('[{\mu}m]');
%     xlim([0 length(Interpolated_ol)]);
%     subplot(2,1,2);
%     plot(Interpolated_witness);
%     hold on;
%     plot(Domain_From,Interpolated_witness(Domain_From),'ok');
%     plot(Domain_To,Interpolated_witness(Domain_To),'or');
%     title('Witness Sensor');
%     ylabel('[{\mu}m]');
%     xlim([0 length(Interpolated_witness)]);
%     
   
    % Finds very important peaks
    [pks,locs]=findVIpeaks(True_pks,True_locs,mode_algo);
    
    % Peak ratio
    ref_peak=max(pks); 
    pkr=[];
    for pkr_iter=1:(length(pks))
        pkr(pkr_iter)=(pks(pkr_iter))/ref_peak;
    end

    % Returns misalignment parameter in a given range
    gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi; % Gouy phase shift
    [gouy_pkr,gouy_locs] = Gouy_Sort(pkr(:),locs(:),gouy_shift);
    
    % Flips the order of gouy_pkr wrt the witness sensor
    [gouy_pkr,gouy_locs]=ToFlipOrNotToFlip(Interpolated_witness,Domain_From,Domain_To,gouy_pkr,gouy_locs);

    
%% Uncomment for the plot of the flipping condition    
%     figure;
%     plot(Domain_From,Interpolated_witness(Domain_From),'ok');
%     hold on;
%     plot(Domain_To,Interpolated_witness(Domain_To),'or');
%     hold on;
%     plot((round((Domain_To-Domain_From)/2))+Domain_From,Interpolated_witness((round((Domain_To-Domain_From)/2))+Domain_From),'ob');
%     hold on;
%     plot([1 (length(Interpolated_witness))],[mean(Interpolated_witness(~isnan(Interpolated_witness))) mean(Interpolated_witness(~isnan(Interpolated_witness)))]);
%     xlim([1 (length(Interpolated_witness))]);
%     ylabel('[{\mu}m]');title('Witness sensor');
%     set(legend(sprintf('Region from: %d',Domain_From),sprintf('Region to: %d',Domain_To),'Mid-region','Mean witness'),'location','NorthEastOutside');
%     hold on;
%     plot(Interpolated_witness);
    
    [Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,gouy_pkr);
    Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1) % Misalignment parameter
%     Ratio_Matrix(Row_Gouy,:) % Estimated misalignment
%     gouy_pkr % Re-ordered peak ratios
%     [c, index]= min(abs(Ratio_Matrix(:,1)-test_value));
%     Ratio_Matrix(index,:) % True misalignment
%     Mode_Gouy % Mode number of the highest peak

%% Uncomment for the plot of the selected region
%     figure;
%     subplot(2,1,1);
%     plot(Input_Matrix_16k(:,2));
%     xlim([0 (length(Input_Matrix_16k(:,2)-1))]);
%     title('Full scan');ylabel('Power [W]');
%     subplot(2,1,2);
%     plot(Interpolated_witness(Domain_From:Domain_To),Input_Matrix_16k(Domain_From:Domain_To,2));
%     xlim([min(Interpolated_witness(Domain_From:Domain_To)) max(Interpolated_witness(Domain_From:Domain_To))]);
%     title('Selected region');ylabel('Power [W]');%xlabel('Relative displacement [{\mu}m]');
%     xlabel([Domain_From Domain_To]);
end