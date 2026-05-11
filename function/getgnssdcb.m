function DCB = getgnssdcbJumbo(d, DCB_path)
cd(DCB_path)
% Download GNSS DCB from cddis website [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
% provided by Chinese Academy of Sciences (CAS) or GeoForschungsZentrum Potsdam (GFZ)
% and read DCB

%% check date
today = datetime("today");

date_data = d - (day(d)-1);

if days(today - d) < 25 % 25 days
    date_data = date_data - calmonths(1);
end
disp(date_data)
% get doy calculation
doy_str      = string(date_data,"ddd");
year_str     = string(date_data,"yyyy");

DCB_list = dir("*_" + year_str + doy_str + "0000_01D_01D_DCB.*.gz");

if isempty(DCB_list) % download if DCB file does not exist
    disp("download DCB")
    download_success = false;
    perfix = ["CAS0MGXRAP_", "CAS0OPSRAP_", "GFZ0MGXRAP_"];
    suffix = ["BSX", "BIA", "BSX"];
    url = "ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/" + year_str + "/";
    username = "anonymous:cssrg.telecom@gmail.com";
    try
        ftpobj = ftp(url, username,"TLSMode","opportunistic");
        for i = 1:3
            for attempt = 1:4       
                try
                    % download DCB file (from CAS)
                    DCB_name_gz = perfix(i) + year_str + doy_str + "0000_01D_01D_DCB."+suffix(i)+".gz";
                    mget(ftpobj,DCB_name_gz);
                    % system("curl -u " + username + " -O --ftp-ssl " + url + DCB_name_gz)
                    download_success = true;
                    break;
                catch err
                    disp(err.message)
                    pause(3) %pause, then retry
                end
            end
            if download_success; break; end
        end
    catch err
        disp(err.message);
    end

else % in case file already exist, use it
    disp("use existing DCB file")
    DCB_name_gz = string(DCB_list(1).name);
    %[~,DCB_name,~] = fileparts(DCB_name_gz);
end

%% 2. decompress DCB file
gunzip(DCB_name_gz);
[~,DCB_name,~] = fileparts(DCB_name_gz);
%% Read DCB file
fileID = fopen(DCB_name,"r");

lineNumber = 0;
while ~feof(fileID)
    line = fgetl(fileID);
    lineNumber = lineNumber + 1;
    
    if startsWith(line, "*BIAS SVN_")
        fprintf('Found at line %d: %s\n', lineNumber, line);
        idx_header = lineNumber;
        break; % Stop after finding the first instance
    end
end

while ~feof(fileID)
    line = fgetl(fileID);
    lineNumber = lineNumber + 1;
    
    if startsWith(line, "-BIAS/SOLUTION")
        fprintf('Found at line %d: %s\n', lineNumber, line);
        idx_end = lineNumber-1;
        break; % Stop after finding the first instance
    end
end

frewind(fileID)
C = textscan(fileID,"%4s%6s%4s%5s%9s%5s%16s%15s%3s%24f%12f",idx_end-idx_header,"HeaderLines",idx_header,"MultipleDelimsAsOne",false,"Whitespace",'','CollectOutput',true);
C{1} = strtrim(C{1});
% C{3} = strtrim(C{3});
fclose(fileID);

%% find GNSS station index
idx = find(~ismissing(C{1}(:,4)),1)-1;

%% find PRN
% sys = C{1}(:,3);
% prn = C{2};
sys = extractBefore(C{1}(1:idx,3),2);
prn = str2double(extractAfter(C{1}(1:idx,3),1));

%% OBS1 and OBS2
OBS1 = C{1}(1:idx,5);
OBS2 = C{1}(1:idx,6);

%% raw DCB
rDCB = C{2}(1:idx,1);

%% map to the results
sat_list = ["GPS","GLO","GAL","BDS","QZS"];
sat_char = ['G','R','E','C','J'];

for i = 1:length(sat_list)
    mask = find(strcmp(sys, sat_char(i)));
    if ~isempty(mask)
        DCB.(sat_list(i)).OBS1 = OBS1(mask);
        DCB.(sat_list(i)).OBS2 = OBS2(mask);
        DCB.(sat_list(i)).PRN  = prn(mask);
        DCB.(sat_list(i)).val  = rDCB(mask);
    end
end
