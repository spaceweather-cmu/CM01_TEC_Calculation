function DCB = getgnssdcbJumbo(d, DCB_path)
cd(DCB_path)
% Download GNSS DCB from cddis website [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
% provided by Chinese Academy of Sciences (CAS) or GeoForschungsZentrum Potsdam (GFZ)
% and read DCB

%%
%% check date
today = datetime("today");

date_data = d - (day(d)+1);

if days(today - d) < 25 % 25 days
    date_data = date_data - calmonths(1);
end
% get doy calculation
doy_str      = string(date_data,"d");
year_str     = string(date_data,"yyyy");

DCB_list = dir("*_" + year_str + doy_str + "0000_01D_01D_DCB.*.gz");

if isempty(DCB_list) % download if DCB file does not exist
    download_success = false;

    perfix = ["CAS0MGXRAP_", "CAS0OPSRAP_", "GFZ0MGXRAP_"];
    suffix = ["BSX", "BIA", "BSX"];
    for attempt = 1:4
        for i = 1:3
            try
                % download DCB file (from CAS)
                DCB_name_gz = perfix(i) + year_str + doy_str + "0000_01D_01D_DCB."+suffix(i)+".gz";
                url = "ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/" + year_str;
                ftpobj = ftp(url,"anonymous:cssrg.telecom@gmail.com");
                mget(ftpobj,DCB_name_gz);
                download_success = true;
                break;
            catch err
                disp(err.message)
            end
        end
        if download_success; break; end
    end
else
    DCB_name_gz = string(DCB_list(1).name);
    %[~,DCB_name,~] = fileparts(DCB_name_gz);
end


%% 2. decompress DCB file
gunzip(DCB_name_gz);
[~,DCB_name,~] = fileparts(DCB_name_gz);
%% Read DCB file
fileID = fopen(DCB_name);
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
