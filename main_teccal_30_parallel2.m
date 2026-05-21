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
main_path = "D:\Tat_ss\IRI\TEC\github\CM01_TEC_dev";             % Program path
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

[~, outname_list, ~] = fileparts(filelist);
DT_list = datetime("1-Jan-" + year_str) + (str2double(doy_list)-1);

N = numel(filelist);

%listing needed DCB
DCB_file_list = strings(1,N);
DCB_file_list(1) = getgnssdcb(DT_list(1),DCB_path); % assign first element with random file name, will be deleted
DCB1 = readgnssdcb(DCB_file_list(1),DCB_path);
DCB_list = repmat(DCB1,1,N);
DCB_list(1) = DCB1;

for i = 2:N
    % outname = char(outname); %convert to single-quote string (array of char)
    d = DT_list(i); % datetime is created based on available *.25/26n files 
    DCB_file_list(i) = getgnssdcb(d,DCB_path);
    % append if DCB of such file is not obtained yet
    disp(DCB_file_list(i))
    if strcmp(DCB_file_list(i),DCB_file_list(i-1))
        DCB_list(i) = DCB_list(i-1);
    else
        DCB_list(i) = readgnssdcb(DCB_file_list(i),DCB_path);
    end
end

% sharedDCB = parallel.pool.Constant(DCB_list);
% sharedidx = parallel.pool.Constant(index_list);
parfor i = 1:N
    
    outname = outname_list(i);
    doy = str2double(extractBetween(outname,5,7));
    d = DT_list(i);
    % station = extractBefore(outname,5);
    
    disp(outname)
    % disp(station)
    disp(d)

    if exist(mat_path+outname+".mat","file")
        continue
    end
    % [can skip this] Copy files from NAS (server 1) (need to connect the same LAN)
    % nasstatus      = dlRNX3fromNAS(d,stationrecallist,R_path);
    % delete("*n") %% remove nav file, use nav from CDDIS
    % Download NAV from CDDIS [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/data/daily/2024/brdc]
    navstatus      = getgnssnav(d,RINEX_path);
    % Check RINEX file
    file_rcvstatus = checkRINEX(d,RINEX_path);
    % Read RINEX file and Calculate TEC/ROTI and save in .mat file
    cal_status     = rnx2tec30(file_rcvstatus,d,DCB_list(i),RINEX_path,mat_path,outname);
end
% mat21Dgraph30(d,station,S_path,F_path)

%% ROTI keogram
% [TIMES, IND, vTEC, ROTI, ipplat, ipplon] = mat2matrix(d,S_path);
%matrix2rotikeogram(d,D_path,F_path,TIMES,IND,ROTI,ipplat,ipplon)
% Delete observation file to save memory
% cd(RINEX_path)
% delete('*d','*o','*n')
cd(main_path) 
