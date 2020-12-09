function [Y3] = LinearInterp(T1,T2,Y1,Y2,T3);

% Does Linear Interpolation

m = (Y2-Y1)/(T2-T1);
b = Y2 - (m*T2);
Y3 = (m*T3) + b;
