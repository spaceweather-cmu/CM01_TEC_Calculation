function [rcvstatus] = checkRINEX(d,rinex_path)
%% Check and count RINEX files

% doy calculation
[yr,doy] = find_doy(d);
Year     = num2str(yr);
Year2    = Year(3:4);
doy      = num2str(doy,'%.3d');
c_path = [pwd '\'];
disp('>>>>>>> Check RINEX file <<<<<<<<')
disp(['DOY: ' doy ', Year: ' Year])

% check .rnx or .crx first and rename
cd(rinex_path)
file_crx = dir([rinex_path '*.crx']);
if ~isempty(file_crx)
    for crx = 1:length(file_crx)
        system(['CRX2RNX.exe ' file_crx(crx).name])
    end
end
file_rnx = dir([rinex_path '*.rnx']);
if ~isempty(file_rnx)
    for rnx = 1:length(file_rnx)
        sttname = file_rnx(rnx).name(1:4);
        movefile([rinex_path file_rnx(rnx).name],[rinex_path sttname doy '0.' Year2 'o']);
    end
end
cd(c_path)
fileR_ofile = dir([rinex_path '*' doy '0.' Year2 '*o']);
rcvstatus = cell(length(fileR_ofile),4);
for st = 1:length(fileR_ofile)
    station_name = fileR_ofile(st).name(1:4);
    fileR = dir([rinex_path station_name doy '0.' Year2 '*']);
    rcvstatus(st,1) = {station_name};
    if isempty(fileR)
        rcvstatus(st,2) = {nan};
        rcvstatus(st,3) = {nan};
        rcvstatus(st,4) = {0};
        disp(['No file at ' station_name ' doy ' doy])
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