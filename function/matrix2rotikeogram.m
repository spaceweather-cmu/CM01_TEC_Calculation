function matrix2rotikeogram(d,d_path,F_path,times,ind,ROTI,ipplat,ipplon)
% start stop time (index in sec)
stt = 1; % 4320043200
stp = 86400; % 72000 79200
% sunset
sunset_oct = [42780,41580,40380,39000,37800]; 
% Thailand regions
latmin = 0;
latmax = 25;
lonmin = 90;
lonmax = 110;
% file name
[~,doy] = find_doy(d);
doy  = num2str(doy,'%.3d');
date = datevec(d);
yr = num2str(date(1),'%.4d');

current_path = [pwd '\'];
% down sampling to 5 min
sp = min(min(diff(times)));
stt5 = ceil(stt/sp);
stp5 = ceil(stp/sp);
sp5  = ceil((300/sp));
ind_5    = ind(stt5:sp5:stp5,:);
times_5  = times(stt5:sp5:stp5,:);
obsroti  = ROTI(stt5:sp5:stp5,:);
ipplt    = ipplat(stt5:sp5:stp5,:);
ippln    = ipplon(stt5:sp5:stp5,:);
UTCtime = gpst2time(min(times_5')');
UTCtime = UTCtime(:,4)*60*60 + UTCtime(:,5)*60 + UTCtime(:,6);
UTCtime(UTCtime==0) = 1; % cannot be zero
UTCtime = UTCtime.*ones(size(obsroti));
% seperate roti < 0.3
obsroti03 = obsroti;
obsroti(obsroti<=0.3) = nan;
obsroti03(obsroti03>0.3) = nan;

% load('cmap_rotikeogram.mat', 'cmap_rotikeogram') % color
load('cmap_rotikeogram_2.mat', 'cmap_rotikeogram') % color
if ~isempty([F_path yr]);mkdir([F_path yr]);end
if ~isempty([F_path yr '\' doy]);mkdir([F_path yr '\' doy]);end
save_path = [F_path yr '\' doy '\'];

try
    nImages    = size(ind_5,1);
    disp('===== lattitude ROTI Keogram ===== ');
    h1 = figure;
    hold on
    grid on
    for idx = 1:nImages % 5 min sample
        scatter(UTCtime(idx,:)/3600,ipplt(idx,:),3,obsroti03(idx,:),'filled','Marker','s') % Draw gray
        % scatter(UTCtime(idx,:)/3600,ipplt(idx,:),20,obsroti(idx,:),'filled')   % Draw yellow and red 
        colorbar;
        % clim([0 (fix(nanmax(nanmax(TEC)))/5)+1)*5]) % axis
        clim([0 1]) % axis

        colormap(cmap_rotikeogram);
    end
    for idx = 1:nImages % 5 min sample
        % scatter(UTCtime(idx,:)/3600,ipplt(idx,:),3,obsroti03(idx,:),'filled') % Draw gray
        scatter(UTCtime(idx,:)/3600,ipplt(idx,:),20,obsroti(idx,:),'filled','Marker','s')   % Draw yellow and red 
        colorbar;
        % clim([0 (fix(nanmax(nanmax(TEC)))/5)+1)*5]) % axis
        clim([0 1]) % axis
        
        colormap(cmap_rotikeogram);
    end
    date1st = gpst2time(max(max(times_5)));
    mth   = num2str(date1st(2),'%.2d');
    dat    = num2str(date1st(3),'%.2d');
    % axis([stt/3600 stp/3600 latmin latmax])
    axis([0 24 latmin latmax])
    xticks(0:2:24)
    xlabel('Time (UTC)'), ylabel('Latitude (Degree)')
    title(['ROTI(TECU/min) Keogram Lat Date: ' yr mth dat '_  DOY ' doy])
    cd(save_path)
    sf1 = ['Keogram_ROTI_Lat_' yr mth dat '_' doy];
    h1.Position = [100 130 700 350];
    saveas(h1,sf1,'jpg')
    saveas(h1,sf1,'fig')
    copyfile([sf1 '.jpg'],[d_path 'dailyROTIlatkeogram.jpg']);
    cd(current_path)


    disp('===== longitude ROTI Keogram ===== ');
    h2 = figure;
    hold on
    grid on
    for idx = 1:nImages % 5 min sample
        scatter(UTCtime(idx,:)/3600,ippln(idx,:),3,obsroti03(idx,:),'filled','Marker','s') % Draw gray
        % scatter(UTCtime(idx,:)/3600,ippln(idx,:),50,obsroti(idx,:),'filled')   % Draw yellow and red 
        colorbar;
        % clim([0 (fix(nanmax(nanmax(TEC)))/5)+1)*5]) % axis
        clim([0 1]) % axis

        colormap(cmap_rotikeogram);
    end
    for idx = 1:nImages % 5 min sample
        % scatter(UTCtime(idx,:)/3600,ippln(idx,:),3,obsroti03(idx,:),'filled') % Draw gray
        scatter(UTCtime(idx,:)/3600,ippln(idx,:),20,obsroti(idx,:),'filled','Marker','s')   % Draw yellow and red 
        colorbar;
        % clim([0 (fix(nanmax(nanmax(TEC)))/5)+1)*5]) % axis
        clim([0 1]) % axis
        
        colormap(cmap_rotikeogram);
    end
    date1st = gpst2time(max(max(times_5)));
    mth   = num2str(date1st(2),'%.2d');
    dat    = num2str(date1st(3),'%.2d');
    axis([stt/3600 stp/3600 lonmin lonmax])
    axis([0 24 lonmin lonmax])
    xticks(0:2:24)
    xlabel('Time (UTC)'), ylabel('Longitude (Degree)')
    title(['ROTI(TECU/min) Keogram Lon Date: ' yr mth dat '_  DOY ' doy])
    cd(save_path)
    sf2 = ['Keogram_ROTI_Lon_' yr mth dat '_' doy];
    h2.Position = [100 130 700 350];
    saveas(h2,sf2,'jpg')
    saveas(h2,sf2,'fig')
    copyfile([sf2 '.jpg'],[d_path 'dailyROTIlonkeogram.jpg']);
    cd(current_path)

    disp('===== ROTI Keogram complete =====');

    % Log
    fid = fopen([current_path 'log_ROTIkeogram.log'],'a');
    fprintf(fid,[datestr(datetime()) '\tROTI keogram doy:' doy ' successfully\n']);
    fclose(fid);
    close all
catch
    close(Video_name);
    fid = fopen([current_path 'log_ROTIkeogram.log'],'a');
    fprintf(fid,[datestr(datetime()) '\tROTI keogram doy:' doy ' ERROR\n']);
    fclose(fid);
    cd(current_path)
    close all
end



