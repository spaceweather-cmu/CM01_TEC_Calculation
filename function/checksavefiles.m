function stationrecallist = checksavefiles(d,station,S_path)

% doy
c_path = [pwd '\'];

year_str = string(d,"yyyy");
doy_str      = string(d,"DDD");
mth_str  = string(d,"MM");
day   = string(d,"d");

% check unzip
zip_results = dir(S_path + year_str + "\" + doy_str + "\*.zip");
if ~isempty(zip_results)
    cd(S_path + year_str + "\" + doy_str + "\")
    unzip(zip_results.name);
    delete(zip_results.name);
    cd(c_path)
end
lsf = 1;
stationrecallist = {};
for st = 1:size(station,2)
    station_name = station{st};
    filename = S_path + year_str + "\" + doy_str + "\*" + station_name + ".mat";
    testfile = dir(filename);
    if isempty(testfile)
        stationrecallist{lsf} = station_name;
        lsf = lsf+1;
    end
end
