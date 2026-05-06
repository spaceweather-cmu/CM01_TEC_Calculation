function mat2csv_rinex2(matfilename,s_path)
% RINEX version 2 from Pat results program
% example
% mat2csv_rinex2('TEC_KMIT_2020_07_18.mat','[your_path]\')

% s_path: save path
filestation = matfilename(1:8);
matfile = load(matfilename);
type = fieldnames(matfile);

% TEC
eval(['VTEC = matfile.' type{3,1} '.vertical;'])
eval(['STEC = matfile.' type{3,1} '.slant;'])
% ROTI
eval(['ROTI = matfile.' type{2,1} ';'])
% IPP lat long
eval(['IPP_lat = matfile.' type{4,1} '.IPP_lat;'])
eval(['IPP_lon = matfile.' type{4,1} '.IPP_long;'])

% date & time
date = type{1,1};
date = date(5:end);
year = date(1:4);
mth  = date(6:7);
dt   = date(9:10);
SOD = 1:86400;
SOD = SOD';
% system
system = repmat("GPS", size(VTEC,1), 1);

% make Table
T = table(system,SOD,VTEC,STEC,ROTI);
outputFilename = [s_path filestation '_' year mth dt '.csv'];
writetable(T, outputFilename);

