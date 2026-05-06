function DCB = getgnssdcb(d,DCB_path)

% Download GNSS DCB from cddis website [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
% provided by Chinese Academy of Sciences (CAS) or GeoForschungsZentrum Potsdam (GFZ)
% and read DCB

%%
current_folder = [pwd '\'];
%% check date
cr = datetime('today');
offset    = datevec(cr-d);
offset_gap = offset(2)*30*24 + offset(3)*24 + offset(4);

date     = datevec(d);
yr       = date(1);
if offset_gap >= 600 % 25 days
    mth      = date(2);
else
    mth      = date(2)-1;
    if mth == 0 % december of last year
        mth = 12;
        yr = yr-1;
    end
end
dt       = 1; % use first day of month
d       = datetime(yr,mth,dt);
% doy calculation
[~,doy] = find_doy(d);
Year     = num2str(yr);
doy      = num2str(doy,'%.3d');


DCB_namez = ['*_' Year doy '0000_01D_01D_DCB.BSX.gz'];
% DCB_namez = 'GFZ0MGXRAP_20231030000_01D_01D_DCB.BSX.gz';
% DCB_name1 = 'CAS0MGXRAP_20240480000_01D_01D_DCB.BSX.gz';
%
file_DCB = dir([DCB_path DCB_namez]);
% download new file
if isempty(file_DCB)
    DCB_namez = ['*_' Year doy '0000_01D_01D_DCB.BIA.gz'];
    file_DCB = dir([DCB_path DCB_namez]);
    if isempty(file_DCB)
        dl_status = 0;
        round = 0;
        while dl_status == 0 && round <=3
            try
                % download DCB file (from CAS)
                DCB_name1 = ['CAS0MGXRAP_' Year doy '0000_01D_01D_DCB.BSX.gz'];
                source1 = ['ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/' Year '/' DCB_name1];
                cd(DCB_path)
                dcb_cmd1 = ['curl -u anonymous:cssrg.telecom@gmail.com -O --ftp-ssl ' source1];
                system(dcb_cmd1);
                cd(current_folder)
                file_DCB = dir([DCB_path DCB_name1]);
                dl_status = 1;
                if isempty(file_DCB);dl_status=0;end
                if dl_status ==0
                    % download DCB file (from CAS)
                    DCB_name2 = ['CAS0OPSRAP_' Year doy '0000_01D_01D_DCB.BIA.gz'];
                    source2 = ['ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/' Year '/' DCB_name2];
                    cd(DCB_path)
                    dcb_cmd2 = ['curl -u anonymous:cssrg.telecom@gmail.com -O --ftp-ssl ' source2];
                    system(dcb_cmd2);
                    cd(current_folder)
                    file_DCB = dir([DCB_path DCB_name2]);
                    dl_status = 1;
                    if isempty(file_DCB);dl_status=0;end
                    if dl_status ==0
                        % download DCB file (from GFZ)
                        DCB_name2 = ['GFZ0MGXRAP_' Year doy '0000_01D_01D_DCB.BSX.gz'];
                        source2 = ['ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/' Year '/' DCB_name2];
                        cd(DCB_path)
                        dcb_cmd2 = ['curl -u anonymous:cssrg.telecom@gmail.com -O --ftp-ssl ' source2];
                        system(dcb_cmd2);
                        cd(current_folder)
                        file_DCB = dir([DCB_path DCB_name2]);
                        dl_status = 1;
                        if isempty(file_DCB);dl_status=0;end
                    end
                end
            catch
                dl_status = 0;
                round = round +1;
            end
        end
    end
end
%% 2. check DCB file
DCB_namegz = file_DCB(1).name;
gunzip([DCB_path DCB_namegz],DCB_path);
DCB_name = DCB_namegz(1:end-3);
%% Read DCB file
fileID = fopen([DCB_path DCB_name]);
C = textscan(fileID,'%s','Delimiter','\n');
allline = C{1,1};
clear C
fclose(fileID);

ind_header = find(~cellfun('isempty', strfind(allline, '*BIAS SVN_ PRN STATION')));
ind_end    = find(~cellfun('isempty', strfind(allline, '-BIAS/SOLUTION')));

data = allline(ind_header(1)+1:ind_end-1);
char_sdcb = regexp(data, '\s+', 'split');
splitPositions = [4 10 14 24 28 33 69 92];

for i = 1:numel(data)
    % get char
    currentChar = data{i};
    % Split the char using substring
    raw_splitted_data{i} = {currentChar(1:splitPositions(1)-1),...
        currentChar(splitPositions(1):splitPositions(2)-1),...
        currentChar(splitPositions(2):splitPositions(3)-1),...
        currentChar(splitPositions(3):splitPositions(4)-1),...
        currentChar(splitPositions(4):splitPositions(5)-1),...
        currentChar(splitPositions(5):splitPositions(6)-1),...
        currentChar(splitPositions(6):splitPositions(7)-1),...
        currentChar(splitPositions(7):splitPositions(8)-1),...
        currentChar(splitPositions(8):end)};
end
splitted_data = vertcat(raw_splitted_data{:});

%% find GNSS station index
rawSTT = regexp([splitted_data{:,4}], '\s+', 'split');
rawSTT = rawSTT(2:end)';
ind = find(~cellfun('isempty',strfind(splitted_data(:,4),rawSTT(1))));
ind = ind(1);
%% find PRN
rawPRN = regexp([splitted_data{:,3}], '\s+', 'split');
rawPRN = rawPRN(2:ind)';
sys = string(cellfun(@(x) x(1),rawPRN));
prn = str2double(cellfun(@(x) x(2:end), rawPRN, 'UniformOutput', false));

%% OBS1 and OBS2
rawOBS1 = regexp([splitted_data{:,5}], '\s+', 'split');
OBS1 = rawOBS1(2:ind)';
rawOBS2 = regexp([splitted_data{:,6}], '\s+', 'split');
OBS2 = rawOBS2(2:ind)';

%% raw DCB
rawdcb = str2double(regexp([splitted_data{:,8}], '\s+', 'split'));
rDCB = rawdcb(2:ind)';

%% map to the results
% GPS
ind_gps = find(sys == 'G');
if ~isempty(ind_gps)
    DCB.GPS.OBS1 = OBS1(ind_gps);
    DCB.GPS.OBS2 = OBS2(ind_gps);
    DCB.GPS.PRN  = prn(ind_gps);
    DCB.GPS.val  = rDCB(ind_gps);
end
% Glonass
ind_glo = find(sys == 'R');
if ~isempty(ind_glo)
    DCB.GLO.OBS1 = OBS1(ind_glo);
    DCB.GLO.OBS2 = OBS2(ind_glo);
    DCB.GLO.PRN  = prn(ind_glo);
    DCB.GLO.val  = rDCB(ind_glo);
end
% Galileo
ind_gal = find(sys == 'E');
if ~isempty(ind_gal)
    DCB.GAL.OBS1 = OBS1(ind_gal);
    DCB.GAL.OBS2 = OBS2(ind_gal);
    DCB.GAL.PRN  = prn(ind_gal);
    DCB.GAL.val  = rDCB(ind_gal);
end

% Beidou
ind_bds = find(sys == 'C');
if ~isempty(ind_bds)
    DCB.BDS.OBS1 = OBS1(ind_bds);
    DCB.BDS.OBS2 = OBS2(ind_bds);
    DCB.BDS.PRN  = prn(ind_bds);
    DCB.BDS.val  = rDCB(ind_bds);
end

% QZSS
ind_qzs = find(sys == 'J');
if ~isempty(ind_qzs)
    DCB.QZS.OBS1 = OBS1(ind_qzs);
    DCB.QZS.OBS2 = OBS2(ind_qzs);
    DCB.QZS.PRN  = prn(ind_qzs);
    DCB.QZS.val  = rDCB(ind_qzs);
end
