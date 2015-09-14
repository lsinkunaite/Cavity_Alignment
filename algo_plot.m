close all;
clear all;
fitting_path='/home/laurasinkunaite/Finesse2.0/Misalignment/Fitting/';
file_1D_10='1D_test_maxTEM10.txt';file_1D_15='1D_test_maxTEM15.txt';file_1D_20='1D_test_maxTEM20.txt';
file_2D_10='2D_test_maxTEM10.txt';file_2D_15='2D_test_maxTEM15.txt';file_2D_20='2D_test_maxTEM20.txt';
file_3D_10='3D_test_maxTEM10.txt';file_3D_15='3D_test_maxTEM15.txt';file_3D_20='3D_test_maxTEM20.txt';

Matrix_1D_10=csvread(strcat(fitting_path,file_1D_10));
[sorted_1D_10,locs_1D_10]=sort(Matrix_1D_10(:,1));
tmp_1D_10=Matrix_1D_10(:,2); tmp_1D_10=tmp_1D_10(locs_1D_10);
Matrix_1D_15=csvread(strcat(fitting_path,file_1D_15));
[sorted_1D_15,locs_1D_15]=sort(Matrix_1D_15(:,1));
tmp_1D_15=Matrix_1D_15(:,2); tmp_1D_15=tmp_1D_15(locs_1D_15);
Matrix_1D_20=csvread(strcat(fitting_path,file_1D_20));
[sorted_1D_20,locs_1D_20]=sort(Matrix_1D_20(:,1));
tmp_1D_20=Matrix_1D_20(:,2); tmp_1D_20=tmp_1D_20(locs_1D_20);

Matrix_2D_10=csvread(strcat(fitting_path,file_2D_10));
[sorted_2D_10,locs_2D_10]=sort(Matrix_2D_10(:,1));
tmp_2D_10=Matrix_2D_10(:,2); tmp_2D_10=tmp_2D_10(locs_2D_10);
Matrix_2D_15=csvread(strcat(fitting_path,file_2D_15));
[sorted_2D_15,locs_2D_15]=sort(Matrix_2D_15(:,1));
tmp_2D_15=Matrix_2D_15(:,2); tmp_2D_15=tmp_2D_15(locs_2D_15);
Matrix_2D_20=csvread(strcat(fitting_path,file_2D_20));
[sorted_2D_20,locs_2D_20]=sort(Matrix_2D_20(:,1));
tmp_2D_20=Matrix_2D_20(:,2); tmp_2D_20=tmp_2D_20(locs_2D_20);

Matrix_3D_10=csvread(strcat(fitting_path,file_3D_10));
[sorted_3D_10,locs_3D_10]=sort(Matrix_3D_10(:,1));
tmp_3D_10=Matrix_3D_10(:,2); tmp_3D_10=tmp_3D_10(locs_3D_10);
Matrix_3D_15=csvread(strcat(fitting_path,file_3D_15));
[sorted_3D_15,locs_3D_15]=sort(Matrix_3D_15(:,1));
tmp_3D_15=Matrix_3D_15(:,2); tmp_3D_15=tmp_3D_15(locs_3D_15);
Matrix_3D_20=csvread(strcat(fitting_path,file_3D_20));
[sorted_3D_20,locs_3D_20]=sort(Matrix_3D_20(:,1));
tmp_3D_20=Matrix_3D_20(:,2); tmp_3D_20=tmp_3D_20(locs_3D_20);


figure(1)
plot(sorted_3D_10(:,1),tmp_3D_10,'r');
hold on;
plot(sorted_3D_15(:,1),tmp_3D_15,'b');
hold on;
plot(sorted_3D_20(:,1),tmp_3D_20,'k');
hold on;
x2=0:0.01:5; y2=x2;
plot(x2,y2,'-.k');
legend('maxTEM=10','maxTEM=15','maxTEM=20','Location','northwest');
xlim([0 5]);
xlabel('Calculated misalignment');
ylabel('Gouy misalignment');
title({'Misalignment algorithm applied to', 'Finesse simulation (3D case)'});
figure(2)
plot(sorted_3D_10(:,1),tmp_3D_10-sorted_3D_10(:,1),'r');
hold on;
plot(sorted_3D_15(:,1),tmp_3D_15-sorted_3D_15(:,1),'b');
hold on;
plot(sorted_3D_20(:,1),tmp_3D_20-sorted_3D_20(:,1),'k');
hold on;
x2=0:0.01:5; y2=zeros(length(x2));
plot(x2,y2,'-.k');
legend('maxTEM=10','maxTEM=15','maxTEM=20','Location','southwest');
xlim([0 5]);
xlabel('Calculated misalignment');
ylabel('(Gouy-calculated) misalignment');
title({'Misalignment algorithm applied to', 'Finesse simulation (3D case)'});