%% Total Electron Content (TEC) and Rate of TEC change Index (ROTI) calculation 
% Calculate TEC based on dual-frequency receiver (GNSS)
% Original by Napat Tongkasem

% Version 1.00 30 second sampling version 
% (17/03/2024) - Create the program
% (24/10/2024) - Test V 0.80 cannot estimate RINEX 2.xx correctly 
% (21/11/2024) - Test V 1.00 add ROTI keogram creation
%                   * cannot estimate RINEX 2.xx correctly
%                   * cycle-slip correction need to be improved
%                   * inter-system biases need to be improved

% 1. The program need linux command. Cygwin must be installed
% - curl
% can be download at "https://cygwin.com/install.html"
% 
% 2. Main program is main_teccal_30.m
% 
% 3. We have laboratory website, you can visit
% - http://iono-gnss.kmitl.ac.th/
% =================================================
% Advisors: Dr. Pornchai Supnithi, Dr. Lin Min Min Myint
% CSSRG Laboratory
% School of Telecommunication Engineering
% Faculty of Engineering
% King Mongkut's Institute of Technology Ladkrabang
% Bangkok, Thailand
% =================================================

close all;clear
warning off

% =========== Program's path ==========================
p_path = 'C:\Users\Jumbo\Desktop\TEC_CMU\';             % Program path
R_path = [p_path 'RINEX\'];     % RINEX path
if ~exist([p_path 'result\'],"dir");mkdir([p_path 'result\']);end
% mat results path
S_path = [p_path 'result\matfile\'];
if ~exist(S_path,"dir");mkdir(S_path);end
% figure and video result path
F_path = [p_path 'result\figure\'];
if ~exist(F_path,"dir");mkdir(F_path);end
D_path = [p_path 'result\daily\']
if ~exist(D_path,"dir");mkdir(D_path);end
       % .mat Results path
        % figure and video Results path

DCB_path   = [p_path 'DCB\'];                   % DCB path
path(path,[p_path 'function']);

%[yr,doy] = find_doy(d);
%doy      = num2str(doy,'%.3d');
%yr       = num2str(yr);

% date of the file (choose the date of observation file)
yr = '2026'
filelist = char({dir("RINEX\*.26o").name});
for index = 1:size(filelist,1)
    
    [~, outname, ~] = fileparts(filelist(index,:));
    % outname = char(outname); %convert to single-quote string (array of char)
    doy = str2double(extractBetween(outname,5,7));
    d = datetime(['1-Jan-' yr]) + (doy-1);
    station = extractBefore(outname,5);
    
    disp(outname)
    disp(station)
    disp(d)
    
    % check save file
    % stationcall = checksavefiles(d,station,S_path);

    if exist([S_path outname '.mat'],"file")
        continue
    end
    % [can skip this] Copy files from NAS (server 1) (need to connect the same LAN)
    % nasstatus      = dlRNX3fromNAS(d,stationrecallist,R_path);
    % delete([R_path '*n']) %% remove nav file, use nav from CDDIS
    % Download NAV from CDDIS [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/data/daily/2024/brdc]
    navstatus      = getgnssnav(d,R_path);
    % Download DCB from CDDIS [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
    DCB            = getgnssdcb(d,DCB_path);
    % Check RINEX file
    % file_rcvstatus = checkRINEX(d,R_path);
    % Read RINEX file and Calculate TEC/ROTI and save in .mat file
    % cal_status     = rnx2tec30(file_rcvstatus,d,DCB,R_path,S_path,outname);
end
% mat21Dgraph30(d,station,S_path,F_path)

%% ROTI keogram
% [TIMES, IND, vTEC, ROTI, ipplat, ipplon] = mat2matrix(d,S_path);
%matrix2rotikeogram(d,D_path,F_path,TIMES,IND,ROTI,ipplat,ipplon)
% Delete observation file to save memory
cd(R_path)
% delete('*d','*o','*n')
cd(p_path)
