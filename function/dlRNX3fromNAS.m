function [nasstatus] = dlRNX3fromNAS(d,station,rinex_path)
% Copy file from NAS (server1)
%
% Station = {'CHMA','NUO2','STFD','KMI6','CPN1','RUTI','CADT'};
% Station = {'UDON','KMI6'};
% Station lists
%====== DPT ======
% 'CHAN'; % Chantaburi
% 'CHMA'; % Chiangmai
% 'CNBR'; % Chonburi
% 'DPT9'; % RAMA9, Bangkok
% 'LPBR'; % Lopburi
% 'NKNY'; % Nakhonnayok
% 'NKRM'; % Nakhonratchasima
% 'NKSW'; % Nakhonsawan
% 'PJRK'; % Prachuapkhirikhan
% 'SISK'; % Sisaket
% 'SOKA'; % Songkhla
% 'SPBR'; % Suphanburi
% 'SRTN'; % Suratthani
% 'UDON'; % Udonthani
% 'UTTD'; % Uttraradit
%====== CSSRG Lab =======
% 'STFD'; % Stamford Unv., Bangkok
% 'KMI6'; % KMITL, Bangkok
% 'CPN1'; % Chumphon
% 'RUTI'; % Korat
% 'NUO2'; % Vientien,Laos
% 'CADT'; % Phnom panh, Cambodia
NAS_IP = '\\192.168.1.250';

% doy calculation
[yr,doy] = find_doy(d);
Year     = num2str(yr);
Year2    = Year(3:4);
doy      = num2str(doy,'%.3d');

%% === Avialable Station list ===
disp(['>>>>>>> Download File From NAS: ' num2str(NAS_IP) '<<<<<<<<<<'])
%% === NAS Connection Testing ===
if exist([NAS_IP '\Public\GNSS_Data\'], 'dir')
    disp(['can connect to CSSRG NAS ' NAS_IP])
else
    disp(['Cannot connect to CSSRG NAS ' NAS_IP])
    nasstatus = 0;
    return;
end

current_path = [pwd '\'];
disp(['DOY: ' doy ', Year: ' Year])

for st = 1:size(station,2)
    station_name = station{st};
    % direct the station file path
    %% === NAS path and  header trailer variable ===%%
    % DPT
    if strcmp('CHAN',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\CHAN\' Year '\'];end
    if strcmp('CHMA',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\CHMA\' Year '\'];end
    if strcmp('CNBR',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\CNBR\' Year '\'];end
    if strcmp('DPT9',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\DPT9\' Year '\'];end
    if strcmp('LPBR',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\LPBR\' Year '\'];end
    if strcmp('NKNY',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\NKNY\' Year '\'];end
    if strcmp('NKRM',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\NKRM\' Year '\'];end
    if strcmp('NKSW',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\NKSW\' Year '\'];end
    if strcmp('PJRK',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\PJRK\' Year '\'];end
    if strcmp('SISK',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\SISK\' Year '\'];end
    if strcmp('SOKA',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\SOKA\' Year '\'];end
    if strcmp('SPBR',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\SPBR\' Year '\'];end
    if strcmp('SRTN',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\SRTN\' Year '\'];end
    if strcmp('UDON',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\UDON\' Year '\'];end
    if strcmp('UTTD',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\DPT_Ntrip\RINEX3\UTTD\' Year '\'];end
    % CSSRG
    if strcmp('STFD',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\GBAS Project\STFD\RINEX3\' Year '\'];end
    if strcmp('KMI6',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\KMITL_Propak6\RINEX3\' Year '\'];end
    if strcmp('CPN1',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\CPN1\RINEX3_daily\' Year '\'];end
    if strcmp('RUTI',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\RUTI\RINEX3\' Year '\'];end
    if strcmp('NUO2',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\NICT\LAOS_NUO2\RINEX3\' Year '\'];end
    if strcmp('CADT',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\NICT\Cambodia_CADT\RINEX3\' Year '\'];end
    if strcmp('KMIT',station_name); NAS_path = [NAS_IP '\Public\GNSS_Data\KMITL_Propak6\RINEX3\' Year '\'];end
    
    % Check file in RINEX (Program) folder
    fileR = dir([rinex_path station_name doy '0.' Year2 '*']);
    if isempty(fileR)
        fileR = dir([NAS_path station_name doy '0*']);
        if isempty(fileR)
            fileR = dir([NAS_path '*' Year doy '0*']);
        end
        try
            for i = 1:length(fileR) % 1 or 2
                copyfile([NAS_path fileR(i).name],rinex_path);
                if ismember('.gz',fileR(i).name)
                    gunzip([rinex_path fileR(i).name],rinex_path);
                    delete([rinex_path fileR(i).name])
                elseif ismember('.zip',fileR(i).name)
                    unzip([rinex_path fileR(i).name],rinex_path);
                    delete([rinex_path fileR(i).name])
                end
                if ismember('rnx',fileR(i).name) % Nav file
                    cd(rinex_path)
                    movefile(fileR(i).name,[station_name doy '0.' Year2 'n']);
                    cd(current_path)
                elseif ismember('crx',fileR(i).name)  % OBS file
                    cd(current_path)
                    copyfile('CRX2RNX.exe',rinex_path)
                    cd(rinex_path)
                    system(['CRX2RNX.exe ' fileR(i).name(1:end-3)])
                    delete([rinex_path fileR(i).name(1:end-3)])
                    movefile([fileR(i).name(1:end-7) '.rnx'],[station_name doy '0.' Year2 'o'])
                    pause(3)
                    cd(current_path)
                elseif num2str(fileR(i).name(end-3)) == 'd' % NUOL
                    cd(current_path)
                    copyfile('CRX2RNX.exe',rinex_path)
                    cd(rinex_path)
                    system(['CRX2RNX.exe ' fileR(i).name(1:end-3)])

                    delete([rinex_path fileR(i).name(1:end-3)])
                    pause(3)
                end
                cd(rinex_path)
            end
            fileR = dir([rinex_path station_name doy '0.' Year2 '*']);
        catch
        end
    end
    nasstatus(st,1) = {station_name};
    if isempty(fileR)
        nasstatus(st,2) = {nan};
        nasstatus(st,3) = {nan};
        nasstatus(st,4) = {0};
        disp(['Not available at ' station_name ' doy ' doy])
    end
    if isscalar(fileR)
        nasstatus(st,2) = {fileR(1).name};
        nasstatus(st,3) = {nan};
        nasstatus(st,4) = {1};
        disp(['station:' station_name ' >> OBS:OK / NAV:No file'])
    end
    if length(fileR) ==2
        nasstatus(st,2) = {fileR(2).name};
        nasstatus(st,3) = {fileR(1).name};
        nasstatus(st,4) = {2};
        disp(['station:' station_name ' >> OBS:OK / NAV:OK'])
    end

end
cd(current_path)
disp('=====================================')
disp(['>>>>>>> Totals: ' num2str(length(station)) ' stations <<<<<<<'])
disp('=====================================')

