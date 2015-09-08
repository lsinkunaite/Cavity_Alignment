close all; 
clear all;

data_path='/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/';
data_name_16k='x-arm_%sline_16k.txt';
data_name_256='x-arm_%sline_256.txt';
Ratio_Matrix=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/ratio_Table.txt');

tL = 2158.28; % Distance to the beam waist
L = 4000.00; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
R_itm = 1939.3;
alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));
z_R=(pi*(power(w0,2)))/lambda; % Rayleigh range

[z,p,k] = butter(5,0.4,'low');
sos = zp2sos(z,p,k);
fvtool(sos,'Analysis','freq')
test_array=[0 0.687242 0.903745 0.747380 6.405156 1.130984 0.945770];

% Iterates over measured data (i = 7)
for i=1:7
    Input_Matrix_16k=csvread(strcat(data_path,sprintf(data_name_16k,num2str(i))));
    Input_Matrix_256=csvread(strcat(data_path,sprintf(data_name_256,num2str(i))));
    %Optical_Lever=Input_Matrix_256(:,3)+Input_Matrix_256(:,4)+Input_Matrix_256(:,6)+Input_Matrix_256(:,7);
    Optical_Lever=Input_Matrix_256(:,3)+Input_Matrix_256(:,4);
    test_value=test_array(i);
    
    % Downsamples 16k matrix
    Input_Matrix_16k=Decimator(Input_Matrix_16k,8);
    % Low-pass filter
    %Input_Matrix_16k=LowPass_Filter(Input_Matrix_16k,4,.4);

    Input_Matrix_16k=sosfilt(sos,Input_Matrix_16k);
    
    %[z2,p2,k2] = butter(6,0.4,'low');
    %sos2= zp2sos(z2,p2,k2);
    %Optical_Lever=sosfilt(sos2,Optical_Lever);
    figure();
    subplot(2,1,1);
    plot(Optical_Lever);
    %hold on;
    %[pks_opt,locs_opt]=findpeaks(Optical_Lever);
    %plot(locs_opt,pks_opt,'^r');
    %xlabel(i);
    %title('Optical Lever');
    
    % Anti-resolution and anti-spike parameters
    antires=10;antispike=.01;
    
    % Ratio between domains
    Domain_factor=(length(Input_Matrix_16k(:,2)))/(length(Input_Matrix_256(:,2)));
    
    % Interpolates info from witness sensors
    x=1:1:(length(Input_Matrix_256(:,2))); % Old domain 
    x_in=x*Domain_factor;
    x_out=1:1:(length(Input_Matrix_16k(:,2))); % New domain
    y=Input_Matrix_256(:,2)+Input_Matrix_256(:,5);
    Interpolated_y=Interpolator(x_in,x_out,y);
    Interpolated_ol=Interpolator(x_in,x_out,Optical_Lever);
    subplot(2,1,2);
    plot(Interpolated_ol);
    
    maxTEM=5;
    mode_algo=maxTEM+1;
    [pks,locs]=findpeaks(Input_Matrix_16k(:,2)');
    [Domain_From,Domain_To]=Extreme(Input_Matrix_16k(:,2),Interpolated_y,pks,locs,0.2);
    [True_pks,True_locs]=findTruepeaks(Input_Matrix_16k(Domain_From:Domain_To,2)',antires,antispike);
    
    fprintf('ol_1=%f, ol_2=%f',Interpolated_ol(Domain_From),Interpolated_ol(Domain_To));
    figure();
    plot(Interpolated_ol);
    hold on;
    plot(Domain_From,Interpolated_ol(Domain_From),'ok');
    plot(Domain_To,Interpolated_ol(Domain_To),'or');
    
    
    [pks,locs]=findVIpeaks(True_pks,True_locs,mode_algo);

    ref_peak=max(pks);
    
    pkr=[];
    for pkr_iter=1:(length(pks))
        pkr(pkr_iter)=(pks(pkr_iter))/ref_peak;
    end

    % Returns misalignment parameter in a given range
    gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi; % Gouy phase shift
    [gouy_pkr,gouy_locs] = Gouy_Sort(pkr(:),locs(:),gouy_shift);
    % Checks peaks both ways [for higher-order modes]
    % [Dist_Gouy,Row_Gouy,Mode_Gouy,Tgouy_pkr]=TrueMisalignment(Ratio_Matrix,gouy_pkr);
    % Checks peaks one way [for lower higher-order modes]
    [Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,gouy_pkr);
    Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1)
%     Ratio_Matrix(Row_Gouy,:)
%     gouy_pkr
%     [c, index]= min(abs(Ratio_Matrix(:,1)-test_value));
%     Ratio_Matrix(index,:)
%     Mode_Gouy

    figure;
    subplot(2,1,1);
    plot(Input_Matrix_16k(:,2));
    xlim([0 (length(Input_Matrix_16k(:,2)-1))]);
    title('Full scan');ylabel('Power [W]');
    subplot(2,1,2);
    plot(Interpolated_y(Domain_From:Domain_To),Input_Matrix_16k(Domain_From:Domain_To,2));
    xlim([min(Interpolated_y(Domain_From:Domain_To)) max(Interpolated_y(Domain_From:Domain_To))]);
    title('Selected region');ylabel('Power [W]');%xlabel('Relative displacement [{\mu}m]');
    xlabel([Domain_From Domain_To]);
    
end