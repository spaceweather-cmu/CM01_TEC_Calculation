function mat21Dgraph30(d,stationlists,S_path,F_path)
%% 1-D TEC and ROTI plotting
% Plot TEC and ROTI value from savepath folder

close all
% each system plot [1=plot,0=no]
eachplot = 1;
% save .fig file ([1:yes,2:no] 150 Mb per file, too big not recommended)
sfig = 0;

%% doy calculation
[yr,doy] = find_doy(d);
date  = datevec(d);
year  = num2str(yr);
mth   = num2str(date(2),'%.2d');
dt    = num2str(date(3),'%.2d');
doy   = num2str(doy,'%.3d');


current_path = [pwd '\'];
if ~isempty([F_path year]);mkdir([F_path year]);end
if ~isempty([F_path year '\' doy]);mkdir([F_path year '\' doy]);end

for st = 1:length(stationlists)
    % try
        close all
        %% load file
        stname = stationlists{st};
        try
            s = dir([S_path year '\' doy '\*' stname '.mat']);
            load([S_path year '\' doy '\' s.name])
            eval(['c_station = ' stname ';'])
        catch
            disp(['No file at ' stname])
            continue
        end
        sys = fieldnames(c_station);
        GNSS_STEC = [];
        GNSS_VTEC = [];
        GNSS_ROTI = [];
        GNSS_nsat = [];
        GNSS_SOD  = [];
        for sm = 1:length(sys)-1
            STEC = [];
            VTEC = [];
            ROTI = [];
            nsat = [];
            eval(['STEC = ' stname '.' sys{sm} '.stec;'])
            eval(['VTEC = ' stname '.' sys{sm} '.vtec;'])
            eval(['ROTI = ' stname '.' sys{sm} '.roti;'])
            eval(['ind   = ' stname '.' sys{sm} '.ind;'])
            eval(['gtime = ' stname '.' sys{sm} '.times;'])
            GNSS_STEC = [GNSS_STEC STEC];
            GNSS_VTEC = [GNSS_VTEC VTEC];
            sod = gpst2sod(gtime);
            GNSS_SOD = [GNSS_SOD sod];
            GNSS_ROTI = [GNSS_ROTI ROTI];
            % if sys{sm} == 'BDS' % skip ROTI grom BDS
            %     Rnan = ROTI.*nan;
            %     GNSS_ROTI = [GNSS_ROTI Rnan];
            % else
            %     GNSS_ROTI = [GNSS_ROTI ROTI];
            % end
            % stt = min(min(ind))-1;
            % stp = max(max(ind));
            % Time_ref = (stt:stp)/3600;                    %   Time rate 1 second
            Time_ref = max(sod')/3600;
            Time_ref_median = max(sod(1:30:end,:)')/3600;     %   Time rate 30 second
            % Time_ref_median = (0:2879)/120;
            % check visible satellites
            for tprn = 1:size(STEC,1)
                vsat = STEC(tprn,:);
                vsat(isnan(vsat)) = [];
                if ~isempty(vsat)
                    nsat(tprn) = length(vsat);
                else
                    nsat(tprn) = nan;
                end
            end
            GNSS_nsat = [GNSS_nsat nsat'];

            if eachplot ==1
                
                % median VTEC
                VTEC_M = median(VTEC',1)';
                for h = 1:length(Time_ref_median)-1
                    samp = 30;
                    VTECR2(:,h+1) = median(VTEC_M(samp*(h-1)+1:samp*h,1));
                    VTECR2(:,1)   = median(VTEC_M(1,1));
                end
                % VTECR = smooth(Time_ref_median,VTECR2,0.5,'rloess');
                VTECR = VTECR2;
                TR_fig = figure;
                TR_fig.Position = [100 100 900 600];
                set(TR_fig, 'Visible', 'off');

                subplot(311) % STEC and VTEC median
                pS = plot(Time_ref(1:30:end),VTEC(1:30:end,:));
                hold on
                pV = plot(Time_ref_median,VTECR,'LineWidth',2,'Color','b');
                % pV = plot(Time_ref,VTEC,'LineWidth',2,'Color','b');
                hold off
                xlim([0 24])
                ylim([0 inf])
                xticks(0:2:24)
                legend([pS(1) pV(1)],'VTEC','median VTEC')
                grid on
                ylabel('TEC (TECU)')
                title([sys{sm} ' TEC at ' stname '-' year '/' mth '/' dt])

                subplot(312) % ROTI
                plot(Time_ref(1:30:end),ROTI(1:30:end,:))
                axis([0 24 0 1])
                grid on
                xticks(0:2:24)
                ylabel('ROTI (TECU/min)')
                title('Rate of TEC change index (ROTI)')

                subplot(313) % Number of satellite
                plot(Time_ref(1:30:end),nsat(1:30:end))
                axis([0 24 0 10])
                xticks(0:2:24)
                grid on
                legend(sys{sm})
                xlabel('Time (UTC)')
                ylabel('Number of satellites')
                title('Number of satellites')
                text(0.5,0.12,'CSSRG Laboratory@KMITL, Thailand.','Color',[0 0 0],'FontSize',6)

                %% save
                % cd([F_path year '\' doy])
                namefig = [F_path year '\' doy '\' stname '_' sys{sm} '_TEC_ROTI' year mth dt];
                saveas(TR_fig,namefig,'jpg')
                % cd(daily_path)
                % saveas(TR_fig,['daily_' stname],'jpg');
                % cd(current_path)
            end
        end
        %% GNSS plot
        Time_ref        = max(GNSS_SOD')/3600;
        Time_ref_median = max(GNSS_SOD(1:30:end,:)')/3600;     %   Time rate 30 second
        VTEC_MG = median(GNSS_VTEC',1)';
        for h = 1:length(Time_ref_median)-1
            samp = 30;
            VTECR2(:,h+1) = median(VTEC_MG(samp*(h-1)+1:samp*h,1));
            VTECR2(:,1)   = median(VTEC_MG(1,1));
        end
        % VTECRG = smooth(Time_ref_median,VTECR2,0.5,'rloess');
        VTECRG = VTECR2;
        gnss_fig = figure;
        gnss_fig.Position = [100 100 900 600];
        % set(gnss_fig, 'Visible', 'off');
        subplot(311) % STEC and VTEC median
        pS = plot(Time_ref(1:30:end),GNSS_VTEC(1:30:end,:));
        hold on
        pV = plot(Time_ref_median,VTECRG,'LineWidth',2,'Color','b');
        % pV = plot(Time_ref,VTEC,'LineWidth',2,'Color','b');
        hold off
        xlim([0 24])
        ylim([0 inf])
        % legend([pS(1) pV(1)],'STEC','VTEC')
        legend([pS(1) pV(1)],'VTEC','median VTEC')
        grid on
        xticks(0:2:24)
        ylabel('TEC (TECU)')
        title(['GNSS TEC at ' stname '-' year '/' mth '/' dt])

        subplot(312) % ROTI
        plot(Time_ref(1:30:end),GNSS_ROTI(1:30:end,:))
        axis([0 24 0 1])
        xticks(0:2:24)
        grid on
        ylabel('ROTI (TECU/min)')
        title('Rate of TEC change index (ROTI)')

        subplot(313) % Number of satellite
        N_total = sum(GNSS_nsat(1:30:end,:)',"omitnan");
        hold on
        plot(Time_ref(1:30:end),GNSS_nsat(1:30:end,:))
        plot(Time_ref(1:30:end-1),N_total,'LineWidth',2,'Color','k');
        hold off
        axis([0 24 0 40])
        grid on
        xticks(0:2:24)
        legend([sys(1:end-1);'GNSS'])
        xlabel('Time (UTC)')
        ylabel('Number of satellites')
        title('Number of satellites')
        text(0.5,0.12,'CSSRG Laboratory@KMITL, Thailand.','Color',[0 0 0],'FontSize',6)

        namefig = [F_path year '\' doy '\' stname '_STEC_ROTI' year mth dt '_' doy];
        saveas(gnss_fig,namefig,'jpg')
        if sfig ==1
            saveas(gnss_fig,namefig,'fig')
        end

        fid = fopen([current_path 'log_1Dgraph.log'],'a');
        fprintf(fid,[datestr(datetime()) '\tCompute the VTEC ' stname ' doy:' doy ' successfully\n']);
        fclose(fid);
        % close all
    % catch
    %     fid = fopen([current_path 'log_1Dgraph.log'],'a');
    %     fprintf(fid,[datestr(datetime()) '\tCompute the VTEC ' stname ' doy:' doy ' ERROR\n']);
    %     fclose(fid);
    %     cd(current_path)
    %     copyfile('notAvailable.jpg',[d_path 'daily_' stname '.jpg']); % copy
    %     close all
    %     continue
    % end
end