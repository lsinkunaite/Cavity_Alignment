%----------------------------------------------------------------
% function [x,y] = freiseout(noplot)
% Matlab function to plot Finesse output data
% Usage: 
%   [x,y] = freiseout    : plots and returns the data
%   [x,y] = freiseout(1) : just returns the data
%           freiseout    : just plots the data
% Created automatically Tue Aug  4 16:22:24 2015
% by Finesse v2.0 (v2.0-21-g3c2d315), 19.05.2014
%----------------------------------------------------------------
function [x,y] = freiseout(noplot)

data = load('freiseout.out');
[rows,cols]=size(data);
x=data(:,1);
y=data(:,2:cols);
mytitle='freiseout                Tue Aug  4 16:22:24 2015';
if (nargin==0)

figure('name','freiseout');
plot(x, y(:,1), x, y(:,2), x, y(:,3), x, y(:,4), x, y(:,5), x, y(:,6), x, y(:,7));
legend('pow n3', 'ad00 n3', 'ad10 n3', 'ad01 n3', 'ad20 n3', 'ad11 n3', 'ad02 n3');
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
