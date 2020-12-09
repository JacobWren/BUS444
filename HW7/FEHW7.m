% Financial Engineering Homework #7
% This version (7C) has complex constraints
% Versioin 7D has simple constraints.  Good to demo both.
% Author LRG
% Does portfolio optimization

clear all;  % reset ram 
 clc;
options = zeros(3,1);
format short g;  % set the way numbers are displayed 

% *****************************Begin Control Panel********************************
swtWrite = 1;

options(1) = 0; % 1 = turn on screen, 0 = off, -1 = surpress warning messages
options(2) = 1e-5; % tollerance for weights, default = le-4
options(3) = 1e-5; % tollerance for objective function, default = le-4

% Expected Retun Grid Parameters
% These are only meaningful if swtERMaxMinHistorical = 0;
swtERMax = .55; % maximum expected return
swtERMin = .05; % minimum expected return
swtERInc = .01; % INCrement between max and min
  % For example, if the swithes are set to 0.15, 0.08, and 0.01 respectively, then the
  % ER-Grid will be [ .08 .09 .10 .11 .12 .13 .14 .15 ];
  % NOTE:  if swtERMaxMinHistorical is not equal to zero, then these three switches 
  %        are ignored completely.

swtERMaxMinHistorical = 20; % A non-negative integer scalar, Never equal to one.
                            % Controls the set of E[R] nodes that we will minimize variance for.
                            % If = 0 then use the max/min grid indicated via the three 
                            %     switches swtERMax, swtERMin and swtERInc.   
                            % If >= 2, then the max and min E[R]'s to use in the E[R]-Grid will 
                            % equal the highest and lowest E[R]'s across all of the stocks.  The value of 
                            % swtERMaxHistorical indicates how many nodes are in the E[R]-Grid.
                            % For example, if the highest and lowest E[R]'s (across the N stocks) are
                            % 0.02 and 0.18 (annualized), and if swtERMaxMinHistorical equals 5, then
                            % the ER-Grid would be = [ .02  .06  .10  .14   .18 ]'.
                            % Note: If value is >= 2 then higher values improve precision, i.e. 100 gives
                            % more precise optimal weight vectors than does 99.  
                          
                            
swtERMethod = 0; % 0 = expected return for each stock estimated as Mu (arith mean), 
                 % 1 = expected return estimated as Mu - (sigma^2)/2
                 %  Note: Other ways, we could do, but are not, include CAPM, APT which could be 
                 % invoked by setting this switch equal to 2 or 3.

swtMinWt = -inf; % Can be a scalar, or an Nx1 vector (with different values in each position).
                 % Puts a lower bound on the weight any stock may have
                 % -inf = short selling allowed, -0.15 means any stock can be shorted up to
                 % 15% of the value of the portfilio, 0 = no short selling allowed               
% swtMinWt =   [ .00 .00 .00 .00 .02 .02 .02 .02 .02 .02 ]';             
                 



swtMaxWt = +inf; % Can be a scalar, or an Nx1 vector (with different values in each position).
                 % Puts an upper bound on the weight any stock may have
                 % use '+inf' to not use an upper bound, use .20 to insure that no
                 % stock comprises more than 20% of the portfolio.
                 
                 % Example (with column vectors of dim Nx1):  
                 % To have the first four stocks (of N=10) be bounded between zero and 0.07 weighting,
                 %   and the last six stocks bounded between 2% and 6% weights, then you would use:
                 % swtMinWt = [ .00 .00 .00 .00 .02 .02 .02 .02 .02 .02 ]' and
                 % swtMaxWt = [ .07 .07 .07 .07 .06 .06 .06 .06 .06 .06 ]' 
% swtMaxWt = [ .34 .34 .34 .34 .16 .16 .16 .16 .16 .16 ]' ;
                 

% The next two switches are for specifying custom linear EQuality constraints, as demonstrated 
% in pages 4-37 and 4-38 of the Matlab optimization manual.
% These switches are NOT to be used for insuring that all weights sum to one, or for insuring that the E[R] of the
% portfilio equals a specific value - those two constraints are to be hardcoded within the loop since they are ALWAYS imposed.
%  The switches below are for additional constraints beyond these two.
%  For example to insure that (i) stocks 1, 3, and 7 weights sum to exactly 0.22, (ii) stocks 1 and 4 weights sum to 0.16, and 
%  (iii) stocks 2 and 8 have their weights equal to each other (i.e. w_2 - w_8 = 0), (Three constraints total) you would use:
%    swtOther_Aeq = [ 1 0 1 0 0 0 1 0 0 0 ; 1 0 0 1 0 0 0 0 0 0 ; 0 1 0 0 0 0 0 -1 0 0 ] and 
%    swtOther_beq = [ 0.22 ; 0.16 ; 0]
% Turn these switches off with =[];

swtOther_Aeq = [ 1 0 1 0 0 0 1 0 0 0 ];
swtOther_beq = [ 0.22 ];

% The next two switches are for specifying custom Linear INequality constraints, as demonstrated 
% in pages 4-37 and 4-38 of the Matlab optimization manual.  Make sure the linear constraint equations are written
% as A*x <= b, not as A*x >= b  
% For example to insure that stocks 5, 8, and 10 have their collective weight between 6% and 40% (two constraints)
% you would use:
% swtOther_A   = [ 0 0 0 0 -1 0 0 -1 0 -1 ; 0 0 0 0 1 0 0 1 0 1 ]; 
% swtOther_b   = [ -0.06 ; +0.40 ];

swtOther_A   = [ 0 0 0 0 -1 0 0 -1 0 -1 ; 0 0 0 0 1 0 0 1 0 1 ]; 
swtOther_b   = [ -0.06 ; +0.40 ];

  
swtRf = .0475; % Risk-free rate, annualized, as a decimal (e.g. 0.052)
% *****************************End Control Panel***********************************
% ReturnDataIn = csvread('/Users/jakewren/Documents/MATLAB/BUS444/CoBPort.csv',1,0);
ReturnDataIn = csvread('CoBPort.csv',1,0);
% Weights = csvread('/Users/jakewren/Documents/MATLAB/BUS444/COBW.csv',1,0);
Weights = csvread('COBW.csv',1,0);
 
ReturnData = ReturnDataIn; 
CleanReturns = all(ReturnData >= -1, 2); % A logical with 0/1's. 1's are for rows ...
% that are greatERNode than or equal to -1 (loose more than 100%, ie everything
% ... you invested). The "2" says read across the columns or along the
% rows. Remember we are deleting the entire row with negative values not the entire column
ReturnData = ReturnData(CleanReturns,:); % take only the rows with 1's.

% lets find the col means, ie average return for each stock
ArithReturns = mean(ReturnData, 1); % means calculated across the rows (hence the 1 ...
% aka down the columns)
swtERNodeMax = 252*max(ArithReturns);
swtERNodeMin = 252*min(ArithReturns);

    if swtERMaxMinHistorical == 0;
        ERNode = swtERMin:swtERInc:swtERMax;
    elseif swtERMaxMinHistorical >= 2;
        Inc = (swtERNodeMax - swtERNodeMin)/(swtERMaxMinHistorical - 1); 
        ERNode = swtERNodeMin:Inc:swtERNodeMax;
    elseif swtERMaxMinHistorical == 1;
            disp("ERNoderor, swtERMaxMinHistorical equals 1")
    end;

    if swtERMethod == 0; % expected return for each stock estimated as Mu (arith mean)
        ER = 252*[ArithReturns(1), ArithReturns(2), ArithReturns(3), ArithReturns(4), ArithReturns(5), ...
             ArithReturns(6), ArithReturns(7), ArithReturns(8), ArithReturns(9), ArithReturns(10)];
    elseif swtERMethod == 1; % expected return estimated as Mu - (sigma^2)/2
        ER = 252*[ArithReturns(1)-((var(ReturnData(:,1)))/2);
        ArithReturns(2)-((var(ReturnData(:,1)))/2), ArithReturns(3)-((var(ReturnData(:,1)))/2), ... 
        ArithReturns(4)-((var(ReturnData(:,1)))/2), ArithReturns(5)-((var(ReturnData(:,1)))/2), ... 
        ArithReturns(6)-((var(ReturnData(:,1)))/2), ArithReturns(7)-((var(ReturnData(:,1)))/2), ... 
        ArithReturns(8)-((var(ReturnData(:,1)))/2), ArithReturns(9)-((var(ReturnData(:,1)))/2), ... 
        ArithReturns(10)-((var(ReturnData(:,1)))/2)];
    end;

if options(1) == 1;
    options = optimset('LargeScale','off','Display','output');
    % options = optimset('LargeScale','off','Display','iter','StepTolerance',options(2),'FunctionTolerance',options(3));
elseif options(1) == 0;
    options = optimset('LargeScale','off','Display','off'); 
elseif options(1) == -1;
    options = optimset('LargeScale','off','Display','final'); 
end;  % options(1) = 1; % 1 = turn on screen, 0 = off, -1 = surpress warning messages

% options(2) = le-5; % tollerance for weights, default = le-4
% options(3) = le-5; % tollerance for objective function, default = le-4

%%% options = optimoptions('fmincon','StepTolerance',options(2),'FunctionTolerance',options(3));
% ConstraintTolerance,options(2)

    

x0 = [.1,.1,.1,.1,.1,.1,.1,.1,.1,.1];
w = x0;

VCV = cov(ReturnData);
    
o = ones(10,1);

if isequal(size(swtMinWt),[1,1]);  
   swtMinWt = swtMinWt' + zeros(10,1); %%% this assumes we are looking at all 10 stocks
end;


if isequal(size(swtMaxWt),[1,1]); 
    swtMaxWt = swtMaxWt' + zeros(10,1); %%% this assumes we are looking at all 10 stocks
end;




% ERNode = [.05:.01:.06];
% find the weights that minimize variance for each expected return
for i=1:length(ERNode);

Aeq0 = [ER(1) ER(2) ER(3) ER(4) ER(5) ER(6) ER(7) ER(8) ER(9) ER(10)];

beq0 = [ERNode(i)]; % The portfolio return must equal the return we are talking about

% weights must sum to 1
Aeq2 = [1 1 1 1 1 1 1 1 1 1];
beq2 = [1];



Aeq = [Aeq0; Aeq2; swtOther_Aeq];
beq = [beq0; beq2; swtOther_beq];

 [w, fval] = fmincon('ObjFun',x0,swtOther_A,swtOther_b,Aeq,beq,swtMinWt,swtMaxWt,[],options);

  WStar1 = w'; % store w
  WStar2(i,:) = WStar1;
  WStarSave = WStar2';
  VarMinSave(i,1) = fval; % store the variance for each E[R]
end;


for i=1:length(ERNode)
    m = ((ERNode(i) - swtRf)/sqrt((252*VarMinSave(i))));
    slope(i,1) = m; % find all slopes
end;

MaxVol = max(VarMinSave);
AnnualVolMax = sqrt(252*MaxVol);
T = max(slope); % tangency point has the steepest slope

% Efficient frontier with a risk free rate:
x = [0,[],(AnnualVolMax)];  % Defines the domain 
y = swtRf + T*x;
plot(x,y)

hold on

plot(sqrt(252*(VarMinSave)),ERNode')  % plot efficient frontier
% axis([0 30 0 0.10]);  % sets lower and upper limits for x and y axis.
xlabel('Annualized Volatility');
ylabel('Expected Return');
title('The efficient frontier with a risk free asset');
axis([0 AnnualVolMax min(ERNode)-.1 max(ERNode)+.1]);
%%

We = Weights(:,4);
CurrentER = (ER*We); % current expected return of portfolio

CurrentVar = 252*(We'*VCV*We); % current variance of portfolio
CurrentSTDV = sqrt(CurrentVar)*100;
['The current standard deviation is ', num2str(CurrentSTDV), '%']

%% second fmincon
for i=1:1;
    
Aeq0 = [ER(1) ER(2) ER(3) ER(4) ER(5) ER(6) ER(7) ER(8) ER(9) ER(10)];
beq0 = [CurrentER];

% weights must sum to 1
Aeq2 = [1 1 1 1 1 1 1 1 1 1];
beq2 = [1];

lb = [ .00 .00 .00 .00 .00 .00 .00 .00 .00 .00 ]';
ub = [ 1 1 1 1 1 1 1 1 1 1 ]';

Aeq = [Aeq0; Aeq2; swtOther_Aeq];
beq = [beq0; beq2; swtOther_beq];

 [O, fval] = fmincon('ObjFun',x0,swtOther_A,swtOther_b,Aeq,beq,lb,ub,[],options);

  OStar1 = O'; % store w
  OStar2(i,:) = OStar1;
  OStarSave = OStar2'; % Optimal weights for current port.
  OVarMinSave(i,1) = fval; % store the variance for each E[R]
end;


['Given the current E[R] of ', num2str(100*CurrentER), '%, the optimal allocation is as follows:']
['The optimal weight of ABT is ', num2str(round((100*OStarSave(1))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(1))/Weights(1,2))),' shares']
['The optimal weight of ADPT is ', num2str(round((100*OStarSave(2))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(2))/Weights(2,2))),' shares']
['The optimal weight of AFS is ', num2str(round((100*OStarSave(3))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(3))/Weights(3,2))),' shares']
['The optimal weight of CHB is ', num2str(round((100*OStarSave(4))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(4))/Weights(4,2))),' shares']
['The optimal weight of HAS is ', num2str(round((100*OStarSave(5))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(5))/Weights(5,2))),' shares']
['The optimal weight of MLHR is ', num2str(round((100*OStarSave(6))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(6))/Weights(6,2))),' shares']
['The optimal weight of OMX is ', num2str(round((100*OStarSave(7))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(7))/Weights(7,2))),' shares']
['The optimal weight of RFH is ', num2str(round((100*OStarSave(8))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(8))/Weights(8,2))),' shares']
['The optimal weight of WFC is ', num2str(round((100*OStarSave(9))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(9))/Weights(9,2))),' shares']
['The optimal weight of WSM is ', num2str(round((100*OStarSave(10))),2),'% or ', num2str(round(((sum(Weights(:,3)))*OStarSave(10))/Weights(10,2))),' shares']
%%


if swtWrite == 1;
    % csvwrite('/Users/jakewren/Documents/MATLAB/BUS444/WStar.out.csv', WStarSave);   
    % csvwrite('/Volumes/JACOBWREN/BUS444/HW7/WStar.out.csv', WStarSave);
    csvwrite('e:\bus444\hw7\WStar.out.csv', WStarSave);
end;

