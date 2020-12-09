% BUS-444, FEHW0 Reads a CSV file, builds a simple gradebook, and writes
% output to disk

clear all; % reset ram
clc; % clears the output screen. Makes the output easier to read.

format short g; % set the way numbers are displayed on the screen
                % "short g" gives 5 digits to the right of the decimal
                % format "bank" gives 2, 
                % format long g gives 15
           
 % ***********************************************************************
 % ********************** Begin Control Panel  ***************************
 % ***********************************************************************
 
 swtHomeworkWeight = .250; % the homework weight - as a decimal
 swtMidtermWeight = .350; % the midterm weight - as a decimal
 swtFinalWeight = .400; % the final exam weight - as a decimal
 
 swtNumStudents = 5; % number of students to process
 
 swtWrite = 1; % turn on/off the CSV output to harddisk 1 = on, 0 = off
 
 % ***********************************************************************
 % ********************** End Control Panel  *****************************
 % ***********************************************************************
 
 
 
%*********************************************************************
%********************  Begin Control Panel As Graded  ********************
%*********************************************************************


    swtHomeworkWeight =  0.500;  % the homework weight - as a decimal 
    swtMidtermWeight  =  0.250;  % the midterm weight - as a decimal 
    swtFinalWeight    =  0.250;  % the final exam weight - as a decimal 

    swtNumStudents = 5;   % number of students to process 

    swtWrite = 1;    % turn on/off the CSV output to harddisk 1=on, 0=off

    
%*********************************************************************
%********************   End Control Panel As Graded **********************
%*********************************************************************


 
% GradeDataIn = csvread('/Users/jakewren/Documents/MATLAB/BUS444/grades.csv');
	
% GradeDataIn = csvread('/Volumes/BUS444/BUS444/HW0/grades.csv');
	

GradeDataIn = csvread('e:\bus444\hw0\Grades.csv');

ComputationStorage = zeros(swtNumStudents, 2) - 9.999; 
% initialize storage matrix to -9.999's

i = 1; % set the counter to 1.0 initially
while i <= swtNumStudents;

    StudentDataNow = GradeDataIn(i,:); % grab the raw data for student i
    
    OverallScore = StudentDataNow(1,2) * swtHomeworkWeight + ...
                   StudentDataNow(1,3) * swtMidtermWeight + ...
                   StudentDataNow(1,4) * swtFinalWeight;
    
    ComputationStorage(i,1) = OverallScore;
    % puts the overall SCORE in the i'th row, 1st place
    
        if OverallScore >= 90; 
            Grade = 4;
        elseif OverallScore < 90 & OverallScore >= 80;
            Grade = 3;
        elseif OverallScore < 80 & OverallScore >= 70;
            Grade = 2;
        elseif OverallScore < 70 & OverallScore >= 60;    
            Grade = 1;
        elseif OverallScore < 60;
            Grade = 0;
        end;
        
    ComputationStorage(i,2) = Grade;
    % store the i'th sudents GRADE to the storage matrix, 2nd column
    
i = i + 1; % increment the counter by one @
end; % this goes with the do loop: while i <= swtNumStudents;

OutputData = [ GradeDataIn  ComputationStorage ] 
% leave off semi-colon to show to screen

if swtWrite == 1;
   % csvwrite('/Users/jakewren/Documents/MATLAB/BUS444/GradeBookOutput.csv',
   % OutputData);
   
    % csvwrite('/Volumes/BUS444/BUS444/HW0/GradeBookOutput.csv', OutputData);
   
   csvwrite('e:\bus444\hw0\GradeBookOutput.csv', OutputData);

end;

