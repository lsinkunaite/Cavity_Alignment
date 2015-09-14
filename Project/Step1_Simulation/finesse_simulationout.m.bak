%----------------------------------------------------------------
% function [x,y] = finesse_simulationout(noplot)
% Matlab function to plot Finesse output data
% Usage: 
%   [x,y] = finesse_simulationout    : plots and returns the data
%   [x,y] = finesse_simulationout(1) : just returns the data
%           finesse_simulationout    : just plots the data
% Created automatically Tue Sep  8 15:21:29 2015
% by Finesse v2.0 (v2.0-21-g3c2d315), 19.05.2014
%----------------------------------------------------------------
function [x,y] = finesse_simulationout(noplot)

data = load('finesse_simulationout.out');
[rows,cols]=size(data);
x=data(:,1);
y=data(:,2:cols);
mytitle='finesse\_simulationout                Tue Sep  8 15:21:29 2015';
if (nargin==0)

figure('name','finesse_simulationout');
plot(x, y(:,1), x, y(:,2), x, y(:,3), x, y(:,4), x, y(:,5), x, y(:,6), x, y(:,7), x, y(:,8), x, y(:,9), x, y(:,10), x, y(:,11), x, y(:,12), x, y(:,13), x, y(:,14), x, y(:,15), x, y(:,16), x, y(:,17), x, y(:,18), x, y(:,19), x, y(:,20), x, y(:,21), x, y(:,22));
legend('pow n2', 'ad00 n1', 'ad10 n1', 'ad01 n1', 'ad20 n1', 'ad11 n1', 'ad02 n1', 'ad30 n1', 'ad21 n1', 'ad12 n1', 'ad03 n1', 'ad40 n1', 'ad31 n1', 'ad22 n1', 'ad13 n1', 'ad04 n1', 'ad50 n1', 'ad41 n1', 'ad32 n1', 'ad23 n1', 'ad14 n1', 'ad05 n1');
set(gca, 'YScale', 'lin');
ylabel('Abs ');
set(gca, 'XLim', [0 0]);
xlabel('');
grid on;
title(mytitle);
end

switch nargout
 case {0}
  clear x y;
 case {2}
 otherwise
  error('wrong number of outputs');
end
