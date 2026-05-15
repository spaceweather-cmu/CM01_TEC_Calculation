function [obs_head, obs_data, nav_head, nav_data] = readrinexfile30(R_path,obsfile_name,navfile_name)
try
[obs_head, obs_data] = obs2data30(char(R_path + obsfile_name));
date = gpst2time(obs_head.te);
dates = datetime(date(1),date(2),date(3));

yr   = string(dates,"yyyy");
doy  = string(dates,"DDD");
% yr  = 
if isnan(navfile_name)
    navfile = dir(R_path + "*" + doy + "0." + extractAfter(yr,2) + "n");
    if isempty(navfile)
        disp('no nav file')
        return
    end
    for nf = 1:size(navfile,1)
        try
            [nav_head, nav_data] = nav2data(char(R_path + navfile(nf).name));
            disp("use navfile: " + navfile(nf).name);
            break
        catch
            continue
        end
    end
else
    [nav_head, nav_data] = nav2data(char(R_path + navfile_name));
end
catch
    obs_head = [];
    obs_data = [];
    nav_head = [];
    nav_data = [];
end

clear mex