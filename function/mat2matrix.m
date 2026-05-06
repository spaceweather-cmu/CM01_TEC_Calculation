function  [times_all, ind_all, vTEC_all, ROTI_all, ipplat_all, ipplon_all] = mat2matrix(dates,S_path)

% constants

[yr,doy] = find_doy(dates);
date = datevec(dates);
yr   = num2str(yr);
mth  = num2str(date(2),'%.2d');
dt   = num2str(date(3),'%.2d');
doy  = num2str(doy,'%.3d');

times_all   = [];
ind_all     = [];
vTEC_all    = [];
ROTI_all    = [];
ipplat_all  = [];
ipplon_all  = [];
statusfile = dir([S_path yr '\' doy '\TECROTI*']);
disp(['Combine matrix from: ' num2str(size(statusfile,1)) ' stations'])
for st = 1:size(statusfile,1)
    % load file
    load([S_path yr '\' doy '\' statusfile(st).name])
    stname = statusfile(st).name(end-7:end-4);
    eval(['c_station = ' stname ';'])
    if stname == 'CPN1';continue;end
    sys = fieldnames(c_station);
    GNSS_times  = [];
    GNSS_ind    = [];
    % GNSS_STEC   = [];
    GNSS_VTEC   = [];
    GNSS_ROTI   = [];
    GNSS_ipplat = [];
    GNSS_ipplon = [];

    for sm = 1:length(sys)-1 % skip rcv position
        times  = [];
        % STEC   = [];
        VTEC   = [];
        ROTI   = [];
        ind    = [];
        ipplat = [];
        ipplon = [];
        eval(['times  = ' stname '.' sys{sm} '.times;'])
        % eval(['STEC   = ' stname '.' sys{sm} '.stec;'])
        eval(['VTEC   = ' stname '.' sys{sm} '.vtec;'])
        eval(['ROTI   = ' stname '.' sys{sm} '.roti;'])
        eval(['ind    = ' stname '.' sys{sm} '.ind;'])
        eval(['ipplat = ' stname '.' sys{sm} '.ipplat;'])
        eval(['ipplon = ' stname '.' sys{sm} '.ipplon;'])
        GNSS_times  = [GNSS_times times];
        % GNSS_STEC   = [GNSS_STEC STEC];
        GNSS_VTEC   = [GNSS_VTEC VTEC];
        GNSS_ROTI   = [GNSS_ROTI ROTI];
        GNSS_ind    = [GNSS_ind ind];
        GNSS_ipplat = [GNSS_ipplat ipplat];
        GNSS_ipplon = [GNSS_ipplon ipplon];
    end
    %% downsampling matrix to 30 second
    dsp_times  = GNSS_times(1:30:end,:);
    % dsp_STEC   = GNSS_STEC(1:30:end,:);
    dsp_VTEC   = GNSS_VTEC(1:30:end,:);
    dsp_ROTI   = GNSS_ROTI(1:30:end,:);
    dsp_ind    = GNSS_ind(1:30:end,:);
    dsp_ipplat = GNSS_ipplat(1:30:end,:);
    dsp_ipplon = GNSS_ipplon(1:30:end,:);
    
    %% output
    times_all = [times_all dsp_times];
    ind_all   = [ind_all dsp_ind];

    vTEC_all  = [vTEC_all dsp_VTEC];
    ROTI_all  = [ROTI_all dsp_ROTI];
    ipplat_all = [ipplat_all dsp_ipplat];
    ipplon_all = [ipplon_all dsp_ipplon];

end
    % times_all = unique(times_all(~isnan(times_all)));
    % ind_all   = unique(ind_all(~isnan(ind_all)));
