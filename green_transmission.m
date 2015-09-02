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

% Iterates over measured data (i = 7)
for i=7:7
    Input_Matrix_16k=csvread(strcat(data_path,sprintf(data_name_16k,num2str(i))));
    Input_Matrix_256=csvread(strcat(data_path,sprintf(data_name_256,num2str(i))));

    Input_Matrix_16k=Decimator(Input_Matrix_16k,8);
    
    
    % Ratio between domains
    Domain_factor=(length(Input_Matrix_16k(:,2)))/(length(Input_Matrix_256(:,2)));

    antires=5;antispike=.02;
    
    % Plots power vs relative displacement
    figure();
    x=1:1:(length(Input_Matrix_256(:,2))); 
    x_in=x*Domain_factor; % Old domain
    x_out=1:1:(length(Input_Matrix_16k(:,2))); % New domain
    y=Input_Matrix_256(:,2)+Input_Matrix_256(:,5);
    Interpolated_y=Interpolator(x_in,x_out,y);

    subplot(3,1,1);
    plot(Interpolated_y,Input_Matrix_16k(:,2));
    xlim([(min(Interpolated_y)) (max(Interpolated_y))]);
    xlabel('Relative displacement of EX and IX at L2 stage');
    %xlabel('Relative displacement between EX and IX L2 stage and reaction chain L2 stage');
    ylabel('Power');
    title('Unfolded power distribution at 16k Hz');
    subplot(3,1,2);
    plot(Input_Matrix_16k(:,2));
    xlim([0 (length(Input_Matrix_16k(:,2)))]);
    ylabel('Power');
    title('Power at 16k Hz');
    subplot(3,1,3);
    plot(Interpolated_y);
    xlim([0 (length(Interpolated_y))]);
    title('Relative displacement of EX and IX at L2 stage');
        
    [Domain_From,Domain_To]=LinearDomain(Interpolated_y');    
    
    figure();
    subplot(3,1,1);
    [pks,locs]=findpeaks(Input_Matrix_16k(Domain_From:Domain_To,2)');
    findpeaks(Input_Matrix_16k(Domain_From:Domain_To,2)');
    title('findpeaks');
    subplot(3,1,2);
    [pks2,locs2]=findAllpeaks(Input_Matrix_16k(Domain_From:Domain_To,2)');
    title('findAllpeaks');
    subplot(3,1,3);
    [pks3,locs3]=findTruepeaks(Input_Matrix_16k(Domain_From:Domain_To,2)',antires,antispike);
    title('findTruepeaks');
    
    mode_algo=5;
    [pks_new,locs_new]=findpeaks(Input_Matrix_16k(:,2)');
    [extreme_pks,extreme_locs]=findExtremePeaks(pks,locs,.5);
    [Domain_From_new,Domain_To_new]=Extreme(Input_Matrix_16k(:,2),pks_new,locs_new,0.5,0.2);
    [pks_local,locs_local]=findTruepeaks(Input_Matrix_16k(Domain_From_new:Domain_To_new,2)',antires,antispike);
    if ((length(pks_local))>mode_algo)
        [pks_algo,locs_algo]=sort(pks_local,'descend');
        locs_algo=locs_local(locs_algo);
        locs_algo=locs_algo(1:mode_algo);
        pks_algo=pks_algo(1:mode_algo);
    else     
        pks_algo=pks_local;locs_algo=locs_local;
    end
    
    pks=pks_algo;
    locs=locs_algo;
    for pkr_iter=1:(length(pks))
        ref_peak=max(pks);
        pkr(pkr_iter)=(pks(pkr_iter))/ref_peak;
    end

    % Returns misalignment parameter in a given range
    gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi; % Gouy phase shift
    [gouy_pks,gouy_locs] = Gouy_Sort(pkr(:),locs(:),gouy_shift);
    [Dist_Gouy,Row_Gouy,Mode_Gouy,Tgouy_pks]=TrueMisalignment(Ratio_Matrix,gouy_pks);
    Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1)
    Ratio_Matrix(Row_Gouy,:)
    Tgouy_pks
    [c, index]= min(abs(Ratio_Matrix(:,1)-2.3516));
    Ratio_Matrix(index,:)
    Mode_Gouy
    Mis_Par_Gouy

    figure();
    plot(Interpolated_y(Domain_From:Domain_To),Input_Matrix_16k(Domain_From:Domain_To,2));
    hold on;
    plot(Interpolated_y(Domain_From+extreme_locs), extreme_pks,'or');
    %xlim([0 (length(Input_Matrix_16k(Domain_From:Domain_To,2))-1)]);
    xlim([(min(Interpolated_y(Domain_From:Domain_To))) (max(Interpolated_y(Domain_From:Domain_To)))]);
    xlabel('Relative displacement of EX and IX at L2 stage [{\mu}m]');
    ylabel('Power');
    title('Unfolded power distribution at 16k Hz');
    
    figure();
    plot(Interpolated_y(Domain_From_new:Domain_To_new),Input_Matrix_16k(Domain_From_new:Domain_To_new,2));
    hold on;
    plot(Interpolated_y(Domain_From_new+locs_algo),pks_algo,'or');
    xlim([(min(Interpolated_y(Domain_From_new:Domain_To_new))) (max(Interpolated_y(Domain_From_new:Domain_To_new)))]);
    xlabel('Relative displacement of EX and IX at L2 stage [{\mu}m]');
    ylabel('Power');
    title('Unfolded power distribution at 16k Hz');
    
end