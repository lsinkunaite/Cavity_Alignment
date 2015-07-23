%----------------------------------------------------------------
% function [x,y] = freiseout(noplot)
% Matlab function to plot Finesse output data
% Usage: 
%   [x,y] = freiseout    : plots and returns the data
%   [x,y] = freiseout(1) : just returns the data
%           freiseout    : just plots the data
% Created automatically Fri Jul 17 14:15:12 2015
% by Finesse v2.0 (v2.0-21-g3c2d315), 19.05.2014
%----------------------------------------------------------------
function [x,y] = freiseout(noplot)

data = load('freiseout.out');
[rows,cols]=size(data);
x=data(:,1);
y=data(:,2:cols);
mytitle='freiseout                Fri Jul 17 14:15:12 2015';
if (nargin==0)

figure('name','freiseout');
plot(x, y(:,1), x, y(:,2), x, y(:,3), x, y(:,4), x, y(:,5), x, y(:,6), x, y(:,7), x, y(:,8), x, y(:,9), x, y(:,10), x, y(:,11), x, y(:,12));
legend('pow n2', 'ad00 n2', 'ad10 n2', 'ad20 n2', 'ad30 n2', 'ad40 n2', 'ad50 n2', 'ad60 n2', 'ad70 n2', 'ad80 n2', 'ad90 n2', 'ad100 n2');
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
