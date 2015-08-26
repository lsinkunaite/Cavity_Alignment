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


[pks,locs]=findAllpeaks(Input_Matrix_2_16k(:,2)');

for pkr_iter=1:(length(pks))
    ref_peak=max(pks);
    pkr(pkr_iter)=(pks(pkr_iter))/ref_peak;
end

gouy_shift=(atan(tL/z_R)-atan(-(L-tL)/z_R))*180/pi; % Gouy phase shift
[gouy_peaks,gouy_locs] = Gouy_Sort(pkr,locs,gouy_shift);

[Dist_Gouy,Row_Gouy,Mode_Gouy]=Misalignment(Ratio_Matrix,gouy_peaks);
Mis_Par_Gouy=Ratio_Matrix(Row_Gouy,1)

%plot_picking(Input_Matrix_1_16k',Input_Matrix_1_256');