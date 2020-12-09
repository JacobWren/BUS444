% FEHW2.m

% This program takes data from Treasury zeros (strips) as obtained 
% from the WSJ, and computes a yield curve.  The program is set up to input a YTM for 
% each Month of each year, in this case November strips are used because they exist in 
% each of the next 28 years.  The program converts these YTM's to YTM's for 1,2,3 ... 
% year horizons (via linear interpolation) then plots the yield curve.  Note that 
% textbooks and theory are based around the type of yield curve we just constructed. i.e.
% one based on zero coupon bonds.  However, most of the financial press reports yield curves
% based on coupon bearing bonds.  That is not a good idea, but it is a lot easier to do, and 
% hence that is why it is done.  Notice that my yield curve drops off after about 21 years, 
% whereas the WSJ yield curve (stapled to the assignment) is always upward sloping.  In fact,
% the WSJ only plots the 'on the run' (most recently issued) bonds for the 3 and 6 month,
% and 1, 2 5, 10 and 30 year horizons.  Notice from the coupon bearing yields in and around
% 2021, the very high YTM's (5.88%), but these don't make the plot cuz these bonds are not
% 'on the run.'  Thus not only is the WSJ yield curve wrong (its using coupon bonds), but
% its incomplete too.


clear all;  % reset ram 
clc;  % clear the output screen


% Add location of LG's custom .m files to the search PATH
% path('c:\code\matlab\larrylib', path);   

format long g;   % set the way numbers are displayed to the screen 
                 % type:   help format at the >> prompt for more info
                 % see also:  format short g
                 %            format bank

%**************** BEGIN CONTROL PANEL ********************

swtToday = 199904;  % YYYYMM. Today's date 

swtYCPlot1 = 1;  % 1= plot current yield curve, 0= dont 

swtForw1 = 3;  % 0 = all forward curve work is off. 
               % = any number, N > 0 indicates the N year forward curve to consturct 
               % e.g. if swtForw1 = 2, then construct the 2 year forward curve 

    swtForwPlot = 1;  % 1= plot forward curve, 0= dont 
    swtForwWrite = 1; % 1 = write ascii file, 0= dont 

  
swtEstYC1 = 5;  % N= estimate the yield curve at year N 
                % 0 = do nothing (off) 
                
      swtEstYCPlot = 1;   % 1= Plot estimate future yield curve, 0=dont 
      swtEstYCWrite = 1;  % 1= write to ascii file, 0= dont 



%**************** END CONTROL PANEL ***********************

%**************** BEGIN CONTROL PANEL Graded by LG ********************

swtToday = 199904;  % YYYYMM. Today's date 

swtYCPlot1 = 0;  % 1= plot current yield curve, 0= dont 

swtForw1 = 8;  % 0 = all forward curve work is off. 
               % = any number, N > 0 indicates the N year forward curve to consturct 
               % e.g. if swtForw1 = 2, then construct the 2 year forward curve 

    swtForwPlot = 0;  % 1= plot forward curve, 0= dont 
    swtForwWrite = 1; % 1 = write ascii file, 0= dont 

  
swtEstYC1 = 8;  % N= estimate the yield curve at year N 
                % 0 = do nothing (off) 
                
      swtEstYCPlot = 1;   % 1= Plot estimate future yield curve, 0=dont 
      swtEstYCWrite = 1;  % 1= write to ascii file, 0= dont 



%**************** END CONTROL PANEL Graded ***********************

% read the CSV file - which was previously saved to .CSV-type in Excel. 

% The input data must be 2 columns as follows:  Column 1 is the date, with format 
% YYYYMM e.g. 200611 for Nov 2006. 
% Column 2 must be quoted price (in 32nds) on Treasury zeros (strips) from WSJ 
% with format XXX.ZZ, e.g. 87.23 
% A price of 87.23 means $87 23/32nds for a zero with $100 face value 
% I used November maturity bonds since they exist in each year.  The same is true of 
% August bonds too.  The data in my file is from WSJ 990331 


InputMatx = csvread('strips.csv') ;   % this is of dim 29x2, via WSJ data
% InputMatx = csvread('/Users/jakewren/Documents/MATLAB/BUS444/strips.csv');



% check  for missing data - we require data spaced 12 months apart 
    Differ1 = InputMatx(2:rows(InputMatx),1) - ...
              InputMatx(1:rows(InputMatx)-1,1) ; 
        
        
%   above Difference vector, should be a constant vector of 100's 

if (std(Differ1) > 0) | (mean(Differ1) ~= 100);   
     % Notice the use of the logical "or" above.
     %   Remember & is for 'and' and | is for 'or'
     %  Also notice the use of NOT-equal as ~=
     
  disp(' ');  % prints a blank line to the screen

  disp( "CRASH.  You do not have bond data (in InputMatx) that is equally spaced" );
  disp("        (with 12 month gaps).  Either you are missing a year, or you have");
  disp("        mixed months of coverage.  Fix it.  Program ending. ");

  return;  % Stop the Matlab program if here.
           % The "return" command stops the Matlab program from continuing. 
           % It's similar to using crash = crash, but "cleaner"

end;



% now compute how far in the future each bond is - in years 
% make sure you understand exactly how this works.  It uses trunc.m
% because Matlab does not have a convienient truncation command

  BondYear  = trunc(InputMatx(:,1)/100);
  BondMonth = InputMatx(:,1) - (BondYear*100);
  TodayYear = trunc(swtToday/100); 
  TodayMonth= swtToday - TodayYear*100;

  MonthsToGo = (BondYear-TodayYear)*12 + (BondMonth-TodayMonth);
  YearsToGo  = MonthsToGo/12;
  
  
 
% Now compute the YTM (in annualized effective terms) for each strip/zero 

YTMData = zeros(rows(InputMatx), 1) -9.999;  % initialize column vector 
  % above will hold annualized effective YTM for each strip 
  
  
i=1;
while i <= rows(InputMatx);
  PriceNowPart1 = trunc(InputMatx(i,2));  % the non 32nd part of the price
  
  PriceNowPart2 = ((InputMatx(i,2)*100)-(PriceNowPart1*100)) / 32;
     % above line is the 32nd part of the price, in dollars (per $100 face bond) 
     % i.e. if the 32nd part is 17 then this gives 17/32 as a decimal (=0.53125).
     
  PriceNow = PriceNowPart1 + PriceNowPart2;  
      % Above has bond prices in decimal form, as if face = $100.  e.g.
      % 53.53125
      
  YTMData(i,1) = (((100/PriceNow)^(1/YearsToGo(i,1))) - 1);  % YTM in decimal form 
       % above is the Annualized effective YTM for each bond, not in pct, i.e. 0.0600 
i=i+1;
end;  % while i <= rows(InputMatx) 

% We now have annualized YTM's for each of the zero coupon (stripped) bonds 

% Now we'd like to find the YTM for 1,2,3,... year zeros 
% The problem is we don't have YTM's for exactly 1,2,... years from today 
% (probably), So need to estimate them.  That is, if the current month is April 
% and the bonds were using are all November maturity, then we have bonds which 
% mature in 7 months, 19 months, 31 months etc.  What we want is the YTM for bonds 
% that mature at 12, 24, 36 months etc.  As a first pass, in order to avoid 
% a lot of hairly bond math, we'll just use linear interpolation.  That is, 
% if we have YTM data (from WSJ) on, say, 7 month and 19 month zeros, then 
% we'll assume the YTM on a 1 year zero is 5/12's of the way between the YTM 
% on the 7 and 19 year zeros 




YTM1Yr = zeros(rows(InputMatx)-1,2) - 9.999;  % initialize 2 column matrix 
				% above will hold the YTM for bonds with maturities at times 
                % 1,2,3... years.  This has 28 rows, not 29 or 30 

i=1;
while i <= rows(InputMatx)-1;

  YTM1Yr(i,1) = i;  % first column holds the year 

  % Get ready to call the proc LinInterp 
  Y1 = YTMData(i,1);    % YTM 1 
  Y2 = YTMData(i+1,1);   % YTM 2 
  T1 = YearsToGo(i,1);   %  Time 1 (in years) 
  T2 = YearsToGo(i+1,1); %  Time 2 (in years) 
  T3 = i;  % the time (in years) we want the YTM for 
  
  YTM1Yr(i,2) = LinearInterp(T1,T2,Y1,Y2,T3);  % calling LinearInterp.m 
      % above line will return the estimated YTM at years 1,2,3, etc... 
      % YOU need to write the linear interpolation (dot m) function.  See
      % homework instructions for constructing the LinearInterp.m function.
     
i=i+1;
end;  % matches with:   while i < rows(InputMatx) 


% We now have a yield curve, based on zeros, giving YTM's at 1,2,3,..., 28 year 
% horizons.  Lets plot it 


if swtYCPlot1 == 1;
    plot(YTM1Yr(:,1),YTM1Yr(:,2));  % plot current yield curve 
    axis([0 30 0 0.10]);  % sets lower and upper limits for x and y axis.
    xlabel('Years');
    ylabel('YTM (as EAR) on Zeros');
    title('Current Yield Curve');
end;



% From this point in the program, we can do several things... 
% We can determine the N-year forward curve.  For example with N=2, we can use 
% the yield curve to estimate what the 2 year rate will be in each of the next 26 
% years.  For example, we could estimate what the 2 year rate would be in each of 
% the next 26 years. From my BUS-342, course this would be a plot of 1_r_3, 2_r_4, 
% 3_r_5, 4_r_6, 5_r_7, ... 26_r_28.  Typically when people talk about the forward 
% curve they mean the 1-year forward curve, but you can talk about any year forward 
% curve.  

if swtForw1 ~= 0;
k = 28 - swtForw1;
for i = 1:k;
F(i,2) =   (( ((1 + YTM1Yr(i+swtForw1,2)) ^(swtForw1+i))  / ((1 + YTM1Yr(i,2))^(i)) ) ^(1/swtForw1) ) -1;
F(i,1) = i;
end;
first = YTM1Yr(swtForw1,2);
first2 = [0 first];
ForRates = vertcat(first2, F);
end;

if swtForwPlot == 1;
    plot(ForRates(:,1),ForRates(:,2));  % plot forward curve 
    axis([0 30 0 0.10]);  % sets lower and upper limits for x and y axis.
    xlabel('Years (t=0 is now)');
    ylabel('Forward Rate');
    title('Forward Rate Curve Constructed from Strips');
end;

% ANOTHER thing we could do is to estimate what the *entire* yield curve would look like 
% at some point in the future.  For example, we could estimate what the yield 
% curve may look like in 4 years.  Since we have only 28 years of data, the estimated 
% yield curve 4 years in future would only have 24 points of data.  Again, from my 
% BUS-342 class, these points would consist of the 24 points:  4_r_5, 4_r_6, 
% 4_r_7, ... 4_r_28. 

if swtEstYC1 ~= 0;
j = 28 - swtEstYC1;
for i = 1:j;
EstYC(i,2) =   (( ((1 + YTM1Yr(i+swtEstYC1,2)) ^(i+swtEstYC1))  / ((1 + YTM1Yr(swtEstYC1,2))^(swtEstYC1)) ) ^(1/i) ) -1;
EstYC(i,1) = i+swtEstYC1;
end;
end;

if swtEstYCPlot == 1;
    plot(EstYC(:,1),EstYC(:,2));  % plot Est. Yield curve 
    axis([0 30 0 0.10]);  % sets lower and upper limits for x and y axis.
    xlabel('Years');
    ylabel('Estimated Interest Rate as EAR');
    title('Estimated Future Yield Curve Constructed from Strips');
end;

% Your HW asignment (HW#2) is to do both of these projects.  See the in-class 
% handout for more on exactly what you need to do.

if swtForwWrite == 1;
    % csvwrite('/Users/jakewren/Documents/MATLAB/BUS444/ForwardOut.csv', ForRates);   
    % csvwrite('/Volumes/JACOBWREN/BUS444/HW2/ForwardOut.csv', ForRates);
    csvwrite('e:\bus444\hw2\ForwardOut.csv', ForRates);
end;

if swtEstYCWrite == 1;
    % csvwrite('/Users/jakewren/Documents/MATLAB/BUS444/ForecastedOut.csv', EstYC);   
    % csvwrite('/Volumes/JACOBWREN/BUS444/HW2/ForecastedOut.csv', EstYC);
    csvwrite('e:\bus444\hw2\ForecastedOut.csv', EstYC);
end;

