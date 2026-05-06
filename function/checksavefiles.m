function stationrecallist = checksavefiles(d,station,S_path)

% doy
c_path = [pwd '\'];
[yr,doy] = find_doy(d);
date = datevec(d);
yr   = num2str(yr);
mth  = num2str(date(2),'%.2d');
dt   = num2str(date(3),'%.2d');
doy  = num2str(doy,'%.3d');

% check unzip
zip_results = dir([S_path yr '\' doy '\*.zip' ]);
if ~isempty(zip_results)
    cd([S_path yr '\' doy '\'])
    unzip(zip_results.name);
    delete(zip_results.name);
    cd(c_path)
end
lsf = 1;
stationrecallist = {};
for st = 1:size(station,2)
    station_name = station{st};
    filename = [S_path yr '\' doy '\*' station_name '.mat'];
    testfile = dir(filename);
    if isempty(testfile)
        stationrecallist{lsf} = station_name;
        lsf = lsf+1;
    end
end
