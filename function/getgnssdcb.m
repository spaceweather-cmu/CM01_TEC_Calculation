function DCB_name_gz = getgnssdcb(d, DCB_path)
cd(DCB_path)
% Download GNSS DCB from cddis website [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
% provided by Chinese Academy of Sciences (CAS) or GeoForschungsZentrum Potsdam (GFZ)
% and read DCB

%% check date
today = datetime("today");

DCB_date = d - (day(d)-1);

if days(today - d) < 25 % 25 days
    DCB_date = DCB_date - calmonths(1);
end
disp(DCB_date)
% get doy calculation
doy_str      = string(DCB_date,"DDD");
year_str     = string(DCB_date,"yyyy");

DCB_list = dir("*_" + year_str + doy_str + "0000_01D_01D_DCB.*.gz");

if isempty(DCB_list) % download if DCB file does not exist
    disp("download DCB")
    download_success = false;
    perfix = ["CAS0MGXRAP_", "CAS0OPSRAP_", "GFZ0MGXRAP_"];
    suffix = ["BSX", "BIA", "BSX"];
    url = "ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/" + year_str + "/";
    % host = "gdc.cddis.eosdis.nasa.gov";
    username = "anonymous:cssrg.telecom@gmail.com";

    for i = 1:3
        fprintf("download file with name %d of 3...",i)
        for attempt = 1:4       
            % download DCB file (from CAS)
            DCB_name_gz = perfix(i) + year_str + doy_str + "0000_01D_01D_DCB."+suffix(i)+".gz";
            [status, ~] = system("..\apps\curl.exe -u " + username + " -O --ssl-reqd " + url + DCB_name_gz); % --ftp-ssl
            if status == 0
                download_success = true;
                break;
            end
        end
        if download_success; sprintf("success\n"); break; end
        fprintf("fail\n")
    end
    if ~download_success; error("fail to download"); end

else % in case file already exist, use it
    DCB_name_gz = string(DCB_list(1).name);
    disp("file already downloaded: " + DCB_name_gz)
    %[~,DCB_name,~] = fileparts(DCB_name_gz);
end
cd("..")