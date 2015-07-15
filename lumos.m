clear all;
close all;

maxTEM=5;
poly_degree=4;
%poly_degree_array=linspace(1,maxTEM,maxTEM+1);
% Only even-mode fitting
poly_degree_array=linspace(0,(maxTEM-mod(maxTEM,2)),((maxTEM-mod(maxTEM,2))/2)+1);

R_etm = 2241.54;
%R_itm = 1939.3;
R_itm = 99999999999;
%L = 4000.0;
L = 2158.28;
lambda = 532e-09;
alpha0 = (power((lambda/pi),.5))*(power((abs((R_etm+R_itm-(2*L)))),.5))/(power((abs(L*(R_etm-L)*(R_itm-L)*(R_etm+R_itm-L))),.25));

alphaITM = (0:0.000001:0.00001);
alpha=[];
p=zeros((maxTEM+1), (poly_degree+1));

%TEMmatrix=zeros(length(alphaITM), (maxTEM+2)*(maxTEM+1)/2);
TEMmatrix=zeros(length(alphaITM), (maxTEM+1));

for j = 1:length(alphaITM)
    fID=fopen('freisekat.txt','w');
    fprintf(fID, 'attr bs1 xbeta %f\n', alphaITM(j));
    
    %alpha(j) = alphaITM(j);
    alpha(j) = alphaITM(j) * 2 / alpha0;
    
    for ii=0:maxTEM
        fprintf(fID, ['ad ad' num2str(ii) '0 ' num2str(ii) ' 0 0 n2\n']);
    end
    fclose(fID);
    system('cat freise.kat freisekat.txt > freiseout.kat');
    system('/home/laura/Finesse2.0/Misalignment/kat freiseout');
    
    results=load('freiseout.out');
    TEMmatrix(j, :)=results(1, 3:end); 
end


%% consolidate amplitude of the same order, e.g. TEM30^2+TEM21^2+TEM12^2+TEM03^2
powerMatrix=zeros(length(alphaITM), maxTEM+1);
for TEMorder=0:maxTEM
    powerMatrix(:,TEMorder+1) = TEMmatrix(:,TEMorder+1).^2;
    %orderIndex = 1+TEMorder*(TEMorder+1)/2;
    %for jj=1:(TEMorder+1)
    %    powerMatrix(:, TEMorder+1) = powerMatrix(:, TEMorder+1)+TEMmatrix(:, orderIndex+jj-1).^2;
    %end
end

%fOD=fopen('fit_results.txt','w');
results_filename1 = 'fit_results_';
results_filename2 = '.txt';
figure_filename2 = '.jpg';
fFIT_filename = 'fit_match_';
fitting_path = '/home/laura/Finesse2.0/Misalignment/Fitting/';
for k=1:(length(powerMatrix(1,:)))
    p(k,:)=polyfit(alpha',powerMatrix(:,k), poly_degree);
    fFIT=fopen(sprintf('%s%s%i%s',fitting_path,fFIT_filename,k,results_filename2), 'w');
    for l=1:(length(poly_degree_array))
        %results_fit = polyfit(alpha',powerMatrix(:,k),poly_degree_array(l));
        fprintf(fFIT, [num2str(polyfit(alpha',powerMatrix(:,k),poly_degree_array(l))) '\n']);
    end
    fclose(fFIT);
    f(k,:)=polyval(p(k,:),alpha');
    T = table(alpha',powerMatrix(:,k),(f(k,:))',(powerMatrix(:,k)-(f(k,:))'),'VariableNames',{'X','Y','Fit','FitError'});
    results_filename = sprintf('%s%s%i%s',fitting_path, results_filename1, k, results_filename2);
    writetable(T,results_filename,'Delimiter',' ');
    %fprintf(fOD, [num2str(p(k,:)) '\n']);
    %fprintf(fOD, [(f(k,:))', ' ', (powerMatrix(:,k)) -((f(k,:))') ' \n']);
    %fprintf(fOD, [table(alpha',powerMatrix(:,k),(f(k,:))',(powerMatrix(:,k)-(f(k,:))'),'VariableNames',{'X','Y','Fit','FitError'})]);
    
    figure_file = figure;
    figure_filename = sprintf('%s%i%s',results_filename1, k, figure_filename2);
    figure_axes=axes('Parent', figure_file);
    hold(figure_axes,'all');
    plot(alpha, powerMatrix(:, k), 'x-');
    hold on;
    plot(alpha, f(k, :), 'r--');
    xlabel('{\alpha}/{\alpha_0}');
    ylabel('Power [W]');
    title(sprintf('Power distribution of HG_{%d}_0 mode',k-1));
    saveas(figure_file, sprintf('%s%s',fitting_path, figure_filename));
end
%fclose(fOD);


totalpower=sum(powerMatrix, 2);

figure
plot(alpha, totalpower, 'r-');
hold on
legend_order = linspace(0,maxTEM,maxTEM+1);
legend_string={'total'};
for ii=1:(maxTEM+1)
    plot(alpha, powerMatrix(:, ii), 'x-');
    xlabel('{\alpha}/{\alpha_0}');
    ylabel('Power [W]');
    title('Power distribution of different HG modes');
    legend_string{ii+1}=num2str(ii-1);
end
%set(legend(cellstr(['HG_' legend_string '_0'])), 'location', 'NorthEastOutside');
set(legend(cellstr(strcat('HG_{',legend_string,'}_0'))), 'location', 'NorthEastOutside');
%set(legend(cellstr(num2str(legend_string', 'HG_{%s}_0'))), 'location', 'NorthEastOutside');
%set(legend(cellstr(num2str(legend_order','HG_{%d}_0'))), 'location', 'NorthEastOutside');