%% Total Electron Content (TEC) and Rate of TEC change Index (ROTI) calculation 
% Calculate TEC based on dual-frequency receiver (GNSS)
% Original by Napat Tongkasem, KMUTT

% Version 1.00 30 second sampling version 
% (17/03/2024) - Create the program
% (24/10/2024) - Test V 0.80 cannot estimate RINEX 2.xx correctly 
% (21/11/2024) - Test V 1.00 add ROTI keogram creation
%                   * cannot estimate RINEX 2.xx correctly
%                   * cycle-slip correction need to be improved
%                   * inter-system biases need to be improved

% =================================================
% Principal investigator: Dr. Pornchai Supnithi, Dr. Lin Min Min Myint
% CMU Astronomy Laboratory
% Department of physics and material sciences
% Faculty of Science
% Chiang Mai University
% Chiang Mai, Thailand
% =================================================

close all;clear
warning off

% =========== Program's path ==========================
main_path = "C:\Users\Jumbo\Desktop\TEC_CMU\";             % Program path
cd(main_path)
addpath("function\"); % for calling function from other directory
RINEX_path = "RINEX\";     % RINEX path
if ~exist("result\","dir"); mkdir("result\"); end
% mat results path
mat_path = "result\mat\";
if ~exist(mat_path,"dir"); mkdir(mat_path); end

% figure and video result path
figure_path = "result\figure\";
if ~exist(figure_path,"dir"); mkdir(figure_path); end
daily_path = "result\daily\";
if ~exist(daily_path,"dir"); mkdir(daily_path); end

% DCB path
DCB_path   = "DCB\";

% date of the file (choose the date of observation file)
year_str = "2026";
yr_str = extractAfter(year_str,2);

filelist = string({dir("RINEX\*."+yr_str+"o").name});
doy_list = extractBetween(filelist,5,7);
date_head = datetime("0000-01-01");

% prepare DCB

for index = 1:size(filelist,1)
    
    [~, outname, ~] = fileparts(filelist(index));
    % outname = char(outname); %convert to single-quote string (array of char)
    doy = str2double(extractBetween(outname,5,7));
    d = datetime("1-Jan-" + year_str) + (doy-1);
    station = extractBefore(outname,5);
    
    disp(outname)
    disp(station)
    disp(d)
    
    % check save file
    % stationcall = checksavefiles(d,station,S_path);

    if exist(mat_path+outname+".mat","file")
        continue
    end
    % [can skip this] Copy files from NAS (server 1) (need to connect the same LAN)
    % nasstatus      = dlRNX3fromNAS(d,stationrecallist,R_path);
    % delete("*n") %% remove nav file, use nav from CDDIS
    % Download NAV from CDDIS [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/data/daily/2024/brdc]
    % navstatus      = getgnssnav(d,RINEX_path);
    % Download DCB from CDDIS [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
    DCB = getgnssdcb(d,DCB_path);
    % Check RINEX file
    % file_rcvstatus = checkRINEX(d,RINEX_path);
    % Read RINEX file and Calculate TEC/ROTI and save in .mat file
    % cal_status     = rnx2tec30(file_rcvstatus,d,DCB,R_path,S_path,outname);
end
% mat21Dgraph30(d,station,S_path,F_path)

%% ROTI keogram
% [TIMES, IND, vTEC, ROTI, ipplat, ipplon] = mat2matrix(d,S_path);
%matrix2rotikeogram(d,D_path,F_path,TIMES,IND,ROTI,ipplat,ipplon)
% Delete observation file to save memory
% cd(RINEX_path)
% delete('*d','*o','*n')
cd(main_path)
