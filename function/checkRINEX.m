function [rcvstatus] = checkRINEX(d,rinex_path)
%% Check and count RINEX files

% doy calculation
doy_str      = string(d,"ddd");
year_str     = string(d,"yyyy");
yr_str = string(d,"yy");
c_path = [pwd '\'];
disp('>>>>>>> Check RINEX file <<<<<<<<')
disp(['DOY: ' doy_str ', Year: ' year_str])

% check .rnx or .crx first and rename
cd(rinex_path)
file_crx = dir([rinex_path '*.crx']);
if ~isempty(file_crx)
    for crx = 1:length(file_crx)
        system(['crx2rnx.exe ' file_crx(crx).name])
    end
end
file_rnx = dir([rinex_path '*.rnx']);
if ~isempty(file_rnx)
    for rnx = 1:length(file_rnx)
        sttname = file_rnx(rnx).name(1:4);
        movefile([rinex_path file_rnx(rnx).name],[rinex_path sttname doy_str '0.' yr_str 'o']);
    end
end
cd(c_path)
fileR_ofile = dir([rinex_path '*' doy_str '0.' yr_str '*o']);
rcvstatus = cell(length(fileR_ofile),4);
for st = 1:length(fileR_ofile)
    station_name = fileR_ofile(st).name(1:4);
    fileR = dir([rinex_path station_name doy_str '0.' yr_str '*']);
    rcvstatus(st,1) = {station_name};
    if isempty(fileR)
        rcvstatus(st,2) = {nan};
        rcvstatus(st,3) = {nan};
        rcvstatus(st,4) = {0};
        disp(['No file at ' station_name ' doy ' doy_str])
    end
    if isscalar(fileR)
        rcvstatus(st,2) = {fileR(1).name};
        rcvstatus(st,3) = {nan};
        rcvstatus(st,4) = {1};
        disp(['station:' station_name ' >> OBS:OK / NAV:No file'])
    end
    if length(fileR) ==2
        rcvstatus(st,2) = {fileR(2).name};
        rcvstatus(st,3) = {fileR(1).name};
        rcvstatus(st,4) = {2};
        disp(['station:' station_name ' >> OBS:OK / NAV:OK'])
    end

end
disp('======================================')
disp(['>>>>>>> Available: ' num2str(length(fileR_ofile)) ' stations <<<<<<<'])
disp('======================================')
end