% Financial Engineering was HW3A (pre 2019)
% But is now HW1 / Matlab (2019+)
% This is clean / works / bug free.
% This version 2019 04 14
% Author:  JW
% Does Capital Budgeting I for different values of P and Q 


clear all;  % reset ram 
clc;  % clear output screen - makes is much easier to debug


format bank;  % set the way numbers are displayed to the screen 
   

%*******************************************************************************
%**************************** BEGINING OF CONTROL PANEL ************************
%*******************************************************************************


% Overall Parameters 
swtProjectLife = 10;    % Expected life of project, in years 
swtWACC = 0.1220;      % Weighted average cost of capital for this project 
swtTaxRate = 0.34;     % Marginal tax rate for the project 

% Capital Expenditures (CapEx) Parameters 
swtCostOfEquip = 65000;   % cost of factory at t=0, assume paid in cash 
swtSalvValue = 20000;     % Est. of Salvage value for deprec purposes 
                          % at the end of the assumed deprec period 
swtMktValue = 40000;      % Est. of the actual mkt value of factory at 
                          % the end of the projects life 
swtDeprecLife =  7;       % The Depreciation period (in yrs) to use. 
                          % Dictated by the IRS and the type of asset used 

% Operating (OpEx) Parameters 
	swtMinP = 5.00;          % minimum Price per unit in the grid 
 	swtMaxP = 20.00;         % maximum Price per unit in the grid 
      swtGridP = 10;          % number of grid points (nodes) to for prices. 
                             % Must be > 1 
      swtMinQ = 500;         % minimum Q in the grid 
      swtMaxQ = 1500;        % maximum Q in the grid 
      swtGridQ = 8;          % number of grid points (nodes) to use with Q 
                             % Must be > 1 
      swtPGrowth = .0500;      % annualized nominal growth in prices beyond t=1 
      swtQGrowth =  -0.0100;    % annualized growth of quantity sold beyond year 1 
                               % Enter above as a decimal, i.e. 0.0100 for +1% growth 

      swtFixOpCost = 2700;     % fixed Op. Costs at t=1 
      swtFixOpCostGr = 0.0300; % annualized growth in fixed Op. costs after year 1 
                               % Enter above as a decimal, i.e. 0.0100 for +1% growth 
                               % A value close to inflation is probably appropriate 
      swtVarOpCost =  3.86;    % variable op. Costs *per unit* at t=1 
      swtVarOpCostGr = 0.0200; % Ann. growth in variable Op. Cost per unit after t=1 
                               % Enter above as a decimal, i.e. 0.0100 for +1% growth 
                               % A value close to inflation is probably appropriate 

% Changes in Working Capital (WC) parameters  
      swtInvent = 0.150;  % Required Invent level as a proportion of next years sales 
      swtAR     = 0.160;  % Acct Rec level as a proportion of same year revenue 
      swtAP     = 0.120;  % Acct Pay level as a proportion of same year revenue 
     
      
% Changes in Maintenance Cash (MC) parameters  
      swtMC   =  3/12 ;  % Maint Cash level as a proportion of same year revenue
          % Note:  Having 3 months of revenue on hand as cash is set via  = 3/12;  
          %  and 45 days via  = 45/365    etc
     
      
 swtWrite = 1;       % 1 = write ascii file to disk, 0 = don't

      
%*****************************************************************************
%***************** END OF CONTROL PANEL **************************************
%*****************************************************************************


% build P and Q grid for the loops 
% These column vectors hold the specific values of P and Q that we'll investigate 


% Now initialize Matricies for CF from Capital Spending, Operations and changes 
% in Working Capital.  

d1 = (swtMaxP-swtMinP)/(swtGridP-1); % incrementor in for loop
d2 = (swtMaxQ-swtMinQ)/(swtGridQ-1); % incrementor in for loop
P = 1;
Q = 1;
y = 0;

for x = swtMinP:d1:swtMaxP; % for loop
    for z = swtMinQ:d2:swtMaxQ; % for loop

[NPVNow] = NPVEngine(x,z,swtProjectLife,swtWACC,swtTaxRate,swtCostOfEquip,swtSalvValue,swtMktValue, ... 
    swtDeprecLife,swtMinP,swtMaxP,swtGridP,swtMinQ,swtMaxQ,swtGridQ,swtPGrowth,swtQGrowth,swtFixOpCost, ...
    swtFixOpCostGr,swtVarOpCost,swtVarOpCostGr,swtInvent,swtAR,swtAP,swtMC); % Calling function NPVNow

y = y + 1;

NPVMat(y) = NPVNow; % storing NPV's into a column vector NPVMat
t = NPVMat;

QGrid(Q,1) = z;
Q = Q + 1;
    end;
PGrid(P,1) = x;
P = P + 1; % building P grid
 end;

QGrid = QGrid(1:swtGridQ,1);

 
NPVMatr = reshape(t,[swtGridQ,swtGridP]); % reshaping matrix "t" accordingly
NPVMatx = NPVMatr';

% Plot %

surfc(PGrid,QGrid,NPVMatx');
colorbar;
xlabel('Price per Unit');
ylabel('Quantity Sold');
zlabel('Fair NPV');
yticks([swtMinQ,swtMaxQ]);
yticks(swtMinQ:100:swtMaxQ);

if swtWrite == 1;

    csvwrite('/Volumes/JACOBWREN/BUS444/HW1B/NPVMatx.csv', NPVMatx);
    
end;
