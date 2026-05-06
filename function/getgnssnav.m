function navstatus = getgnssnav(d,NAV_path)


% Download GNSS DCB from cddis website [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/data/daily/' Year '/brdc/]
% provided by CDDIS, NASA

%%
current_folder = [pwd '\'];
% doy calculation
[yr,doy] = find_doy(d);
Year     = num2str(yr);
doy      = num2str(doy,'%.3d');
% BRDM00DLR_S_20242460000_01D_MN.rnx
% BRDC_namez   = ['BRD400DLR_S_' Year doy '0000_01D_MN.rnx.gz']; % RNX version 4
% BRDC_navname = ['BRD4' doy '0.' Year(3:4) 'n'];
BRDC_namez   = ['BRDM00DLR_S_' Year doy '0000_01D_MN.rnx.gz'];
BRDC_navname = ['BRDM' doy '0.' Year(3:4) 'n'];

file_NAV_z = dir([NAV_path BRDC_namez]);
file_NAV   = dir([NAV_path BRDC_navname]);
% download new file
if ~isempty(file_NAV_z)
    gunzip([NAV_path BRDC_namez],NAV_path);
    cd(NAV_path)
    movefile(BRDC_namez(1:end-3),BRDC_navname)
    cd(current_folder)               
    file_NAV = dir([NAV_path BRDC_navname]);
else
    file_NAV = dir([NAV_path BRDC_navname]);
    if isempty(file_NAV)
        dl_status = 0;
        round = 0;
        while dl_status == 0 && round <=3
            source1 = ['ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/data/daily/' Year '/brdc/' BRDC_namez];
            cd(NAV_path)
            dcb_cmd1 = ['curl -u anonymous:cssrg.telecom@gmail.com -O --ftp-ssl ' source1];
            system(dcb_cmd1);
            cd(current_folder)
            file_NAV = dir([NAV_path BRDC_namez]);
            dl_status = 1;
            if isempty(file_NAV);dl_status=0;end
            round = round +1;
        end
    end
    try
        gunzip([NAV_path BRDC_namez],NAV_path);
        cd(NAV_path)
        movefile(BRDC_namez(1:end-3),BRDC_navname)
        cd(current_folder)
        file_NAV = dir([NAV_path BRDC_navname]);
    catch
        file_NAV = dir([NAV_path BRDC_navname]);
    end
end
if ~isempty(file_NAV)
    navstatus = 1;
else
    navstatus = 0;
end
