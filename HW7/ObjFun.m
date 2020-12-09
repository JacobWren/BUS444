function obj = ObjFun(w)

 ReturnDataIn = csvread('/Users/jakewren/Documents/MATLAB/BUS444/CoBPort.csv',1,0);
 % ReturnDataIn = readtable('/Users/jakewren/Documents/MATLAB/BUS444/CoBPort.csv');
 
ReturnData = ReturnDataIn; 
CleanReturns = all(ReturnData >= -1, 2); % A logical with 0/1's. 1's are for rows ...
% that are greatERNode than or equal to -1 (loose more than 100%, ie evERNodeything
% ... you invested). The "2" says read across the columns or along the
% rows. RemembERNode we are deleting the entire row with negative values not the entire column
% global ReturnData
ReturnData = ReturnData(CleanReturns,:); % take only the rows with 1's.
% global VCV
VCV = cov(ReturnData);
obj = w*VCV*w';