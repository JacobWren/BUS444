function f=trunc(X);
% Simulates the trunc command in Gauss.  i.e. truncates the decimal portion of 
% each element in the matrix x.  It does not do any rounding.
% see round.m for that (you don't need to truncate first)

f= floor(X .* (X > 0)) + ceil(X .* (X < 0));

