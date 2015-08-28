close all; 
clear all;

tL = 2158.28; % Distance to the beam waist
L = 4000.00; % Position of the beam splitter/itm
lambda = 532e-09;
w0 = 8.47e-03; % Beam waist radius
R_etm = 2241.54;
R_itm = 1939.3;
alpha0 = (power((lambda/pi),.5))*(power((tL*(R_etm-tL)),(-.25)));
z_R=(pi*(power(w0,2)))/lambda; % Rayleigh range

Ratio_Matrix=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/ratio_Table.txt');
Input_Matrix_1_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_0_misalignment_16k.txt');
Input_Matrix_1_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_0_misalignment_256.txt');
Input_Matrix_2_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_2line_16k.txt');
Input_Matrix_2_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_2line_256.txt');
Input_Matrix_3_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_3line_16k.txt');
Input_Matrix_3_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_3line_256.txt');
Input_Matrix_4_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_4line_16k.txt');
Input_Matrix_4_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_4line_256.txt');
Input_Matrix_5_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_5line_16k.txt');
Input_Matrix_5_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_5line_256.txt');
Input_Matrix_6_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_6line_16k.txt');
Input_Matrix_6_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_6line_256.txt');
Input_Matrix_7_16k=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_7line_16k.txt');
Input_Matrix_7_256=csvread('/home/laurasinkunaite/Finesse2.0/Misalignment/laura_measurements/x-arm_7line_256.txt');

[Min,I_min]=min(Input_Matrix_2_256(:,2)+Input_Matrix_2_256(:,5));
[Max,I_max]=max(Input_Matrix_2_256(:,2)+Input_Matrix_2_256(:,5));
Range_factor=(length(Input_Matrix_2_16k(:,2)))/(length(Input_Matrix_2_256(:,2)));
Range=[I_min I_max];
Range=sort(Range*Range_factor);

Range_Array=[0 (diff(sign(diff(Input_Matrix_2_256(:,2)+Input_Matrix_2_256(:,5))))==0)' 0];
Iter_Calc=0;
Range_Length=0;
Range_From=0; Range_To=0;
for Iter_Range=1:(length(Range_Array))
    if (Range_Array(Iter_Range)==1)
        Iter_Calc=Iter_Calc+1;
        if (Iter_Calc > Range_Length)
            Range_Length=Iter_Calc;
            Range_From=Iter_Range-Range_Length+1;
            Range_To=Iter_Range;
        end
    else
        Iter_Calc=0;
    end
end

%[pks,locs]=findpeaks(Input_Matrix_2_16k(Range(1):Range(end),2)');
%findpeaks(Input_Matrix_2_16k(Range(1):Range(end),2)');
[pks,locs]=findpeaks(Input_Matrix_2_16k((Range_From*Range_factor):(Range_To*Range_factor),2)');
findpeaks(Input_Matrix_2_16k((Range_From*Range_factor):(Range_To*Range_factor),2)');

for pkr_iter=1:(length(pks))
    ref_peak=max(pks);
    pkr(pkr_iter)=(pks(pkr_iter))/ref_peak;
end

gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi; % Gouy phase shift
[gouy_peaks,gouy_locs] = Gouy_Sort(pkr,locs,gouy_shift);

[Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,gouy_peaks);
Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1)

plot_picking(Input_Matrix_2_16k(:,2)',Input_Matrix_2_256);

figure(3);
x=1:1:(length(Input_Matrix_2_256(:,2))); 
x_in=x*Range_factor; % Old domain
x_out=1:1:(length(Input_Matrix_2_16k(:,2))); % New domain
y=Input_Matrix_2_256(:,2)+Input_Matrix_2_256(:,5);
Interpolated_y=Interpolator(x_in,x_out,y);

subplot(3,1,1);
plot(Interpolated_y,Input_Matrix_2_16k(:,2));
xlim([(min(Interpolated_y)) (max(Interpolated_y))]);
xlabel('Relative displacement of EX and IX at L2 stage');
%xlabel('Relative displacement between EX and IX L2 stage and reaction chain L2 stage');
ylabel('Power');
title('Unfolded power distribution at 16k Hz');
subplot(3,1,2);
plot(Input_Matrix_2_16k(:,2));
xlim([0 (length(Input_Matrix_2_16k(:,2)))]);
ylabel('Power');
title('Power at 16k Hz');
subplot(3,1,3);
plot(Interpolated_y);
xlim([0 (length(Interpolated_y))]);
title('Relative displacement of EX and IX at L2 stage');
