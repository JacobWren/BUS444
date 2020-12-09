% Financial Engineering HW6
% This version 19990515
% Does Capital Budgeting I for different values of P and Q
%   generated from a multivariate normal distribution (Monte Carlo)


clear all;  % reset ram 
clc;  % clear the screen

format bank;  % set the way numbers are displayed 

%path('c:\code\matlab\larrylib', path);


%*************************** BEGIN CONTROL PANEL *****************************

% Price and Quantity Parameters
   swtPMean = 20;    % Expected Price
   swtQMean = 1500;  % Expected Quantity
   swtPStDev = 2;    % Price Standard Deviation
   swtQStDev = 150;  % Quantity Standard Deviation
   swtPQCorr = -.50; % Correlation between Price and Quantity
   
   swtN = 3000; % number of price/quantity draws to make from the bivariate normal distibution
   
% CI and Probability Parameters

swtCI = [ 0.99 0.95 0.50 ]'; 

   % enter [] to find no confidence intervals
   % enter any confidence intervals with a space in between
   % there are NO LIMITS on the number of intervals to be found.
   % eg [.99 .95 .50]
      
swtNPVProb = [ -5000 0 5000 10000 15000 20000 25000 ]';

   % enter [] to find no probabilities
   % enter any values with a space in between and the program will compute
   %    probability of achieving a greater NPV
   % there are NO LIMITS on the number of probabilities to be found.
   % eg [-1000 0 1500]   
   
% Overall Parameters 
	swtProjectLife = 5;    % Expected life of project, in years 
	swtWACC = 0.122;      % Weighted average cost of capital for this project 
	swtTaxRate = 0.34;     % Marginal tax rate for the project 

% Capital Spending Parameters 
	swtCostOfEquip = 65000;   % cost of factory at t=0, assume paid in cash 
	swtSalvValue = 20000;     % Est. of Salvage value for deprec purposes 
   	                       % at the end of the assumed deprec period 
	swtMktValue = 40000;      % Est. of the actual mkt value of factory at 
	                          % the end of the projects life
	swtDeprecLife =  7;       % The Depreciation period (in yrs) to use. 
	                          % Dictated by the IRS and the type of asset used

% Operating Parameters  

	swtPGrowth = 0.0500;      % annualized nominal growth in prices beyond t=1 
   swtQGrowth = -0.0100;    % annualized growth of quantity sold beyond year 1 
                            % Enter above as a decimal, i.e. 0.0100 for +1% growth 

   swtFixOpCost = 2700;     % fixed Op. Costs at t=1 
   swtFixOpCostGr = 0.0300; % annualized growth in fixed Op. costs after year 1 
                            % Enter above as a decimal, i.e. 0.0100 for +1% growth 
                            % A value close to inflation is probably appropriate 
   swtVarOpCost =  3.86;    % variable op. Costs *per unit* at t=1 
   swtVarOpCostGr = 0.0200; % Ann. growth in variable Op. Cost per unit after t=1
                            % Enter above as a decimal, i.e. 0.0100 for +1% growth 
                            % A value close to inflation is probably appropriate 

% Changes in Working Capital parameters  
   swtInvent = 0.150;  % Required Invent level as a proportion of next years sales 
   swtAR     = 0.160;  % Acct Rec level as a proportion of same year revenue 
   swtAP     = 0.120;  % Acct Pay level as a proportion of same year revenue 
   
% Changes in Maintenance Cash;   
   swtMC = 3/12;  % Requried cash as a proportion of same year revenue.
                  % Note:  3/12 implies 3 months of cash (3/12 of a year).


% Program output functions 
   swtPrtNPV = 1; % 1 = print NPV matrix to screen, 0 = don't print 
   swtPrtHist = 1; % 1 = print NPV Histogram to screen, 0 = don't print 
   swtPrtFile = 1; % 1 = print NPV matrix to file, 0 = don't print 
 

%************************** END OF CONTROL PANEL *****************************/

mu = [swtPMean swtQMean]'; % column vector with Price and Quantity
sigma = [(swtPStDev)^2 swtPQCorr*swtPStDev*swtQStDev; swtPQCorr*swtPStDev*swtQStDev (swtQStDev)^2];
% VCV Matx
[f] = MVNormal(mu,sigma,swtN); 
f = f';

g=sign(f); % sign f
h = sum(g(:)==-1); % % find number of negative values in f by summing 

while h > 0;
allPositiveRows = all(f>0, 2); 
f = f(allPositiveRows, :); % removes negative p & q's

    [t] = MVNormal(mu,sigma,swtN-length(f)); % resamples to make f as long as swtN
    t = t';


f = vertcat(f, t); % Adds new P and Q's (t) to f (vertical stack)

g=sign(f);
h = sum(g(:)==-1); % final check for negatives
end;

for i = 1:swtN;
NPV(i) = NPVEngine2(f(i,1),f(i,2),swtProjectLife,swtWACC,swtTaxRate,swtCostOfEquip,swtSalvValue,swtMktValue, ... 
    swtDeprecLife,swtPGrowth,swtQGrowth,swtFixOpCost, ...
    swtFixOpCostGr,swtVarOpCost,swtVarOpCostGr,swtInvent,swtAR,swtAP,swtMC); % Calling function NPVEngine
end;
NPV = NPV';
format bank;
OutMatrix = [f NPV];

if swtPrtHist == 1;
hist(NPV) % histogram of NPV's in scientific notation
title('NPVs from a Bi-Variate Normal Distribution');
xlabel('NPV');
ylabel('Frequency');
end;

mn = mean(NPV); % Calculate the mean
stdv = std(NPV); % Calculate the standard deviation
X = ['The mean NPV is ',num2str(mn),' and the standard deviation is ',num2str(stdv)];
disp(X)
% input('\nsome question :', 's');
fprintf(1, '\n');

X = zeros(length(swtCI), 1) - 9.999; 

S = sort(NPV);
for i = 1:length(swtCI);
L = floor(((((1-swtCI(i,1))/2) * swtN)) + 1);
U = round((((((1-swtCI(i,1))/2)+swtCI(i,1)) * swtN) - 1));
Lower = S(L);
Upper = S(U);
M = ['The ', num2str((swtCI(i)*100)) '% confindence interval is [',num2str(Lower) ' , ' num2str(Upper), ']'];
disp(M);
end; 
fprintf(1, '\n');

for i = 1:length(swtNPVProb);
Prob = ['The probability of achieving a NPV larger than ', num2str(swtNPVProb(i)), ' is ', num2str((sum(S > swtNPVProb(i,1)))/swtN)];
disp(Prob);
end;

if swtPrtNPV == 1;
    OutMatrix
end;

if swtPrtFile == 1;
    % csvwrite('/Users/jakewren/Documents/MATLAB/BUS444/ForecastedOut.csv', EstYC);   
    % csvwrite('/Volumes/JACOBWREN/BUS444/HW6/OutMatrix.csv', OutMatrix);
      csvwrite('e:\bus444\HW6\OutMatrix.csv', OutMatrix);
end;
