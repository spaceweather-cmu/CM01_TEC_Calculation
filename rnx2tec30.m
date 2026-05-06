% TEC and ROTI calculation function
%       read and calculate TEC and ROTI from RINEX files. Then save the
%       results in term of .mat in results folder
% output:
%       calstat  - calculation status (1:done)
% input:
%       rnxstat - cell of RINEX status
%       dates - date time
%       dcb   - satellite DCB
%       R_path   - RINEX folder path
%       S_path   - results folder path
function calstat = rnx2tec30(rnxstat,dates,dcb,R_path,S_path,outname)


[yr,doy] = find_doy(dates);
date_s = datevec(dates);
yr   = num2str(yr);
mth  = num2str(date_s(2),'%.2d');
dt   = num2str(date_s(3),'%.2d');
doy  = num2str(doy,'%.3d');
calstat = cell(size(rnxstat,1),2);
for st = 1:size(rnxstat,1)
    tic
    gnsscons
    %% Check .mat file
    station_name = rnxstat{st,1};
    obsfile_name = rnxstat{st,2};
    navfile_name = rnxstat{st,3};
    navfile = dir([R_path '*' doy '0.' yr(3:4) 'n']);
    filename = [S_path yr '\' doy '\TECROTI_' doy '_' yr mth dt '_' station_name '.mat'];
    matfile = dir(filename);
    if ~isempty(matfile)
        disp(['Skip estimate TEC at ' station_name ', it already calculated'])
        continue;
    end
    disp(['Estimate TEC at ' station_name ' station'])
    %% Read Observation file and Navigation file
    [obs_head, obs_data, nav_head, nav_data] = readrinexfile30(R_path,obsfile_name,navfile_name);
    if isempty(obs_head) || isempty(nav_head)
        disp(['Skip calculate TEC at ' station_name ', RINEX file is missing'])
        return
    end

    % [obs_head, obs_data] = obs2data([R_path obsfile_name]);
    % if isnan(navfile_name)
    %     navfile = dir([R_path '*' doy '0.' yr(3:4) 'n']);
    %     if isempty(navfile)
    % 
    %         disp(['Skip calculate TEC at ' station_name ', nav file is missing'])
    %         return
    %     end
    %     for nf = 1:size(navfile,1)
    %         try
    %             [~, nav_data] = nav2data([R_path navfile(nf).name]);
    %             disp(['use navfile: ' navfile(nf).name]);
    %             break
    %         catch
    %             continue
    %         end
    %     end
    % else
    %     [~, nav_data] = nav2data([R_path navfile_name]);
    % end
    %% find ref position
    refpos = obs_head.posxyz;
    disp(['Calculate TEC at ' station_name ' station'])
    if isempty(refpos)
        try
            refpos = reffromIPPindex(station_name);
        catch
            disp(['Cannot find ref position: ' station_name])
            return
        end
    end
    % refpos = [-1158671.9146  6087821.7336  1503714.9694];
    datestt = gpst2time(obs_head.ts);
    year  = num2str(datestt(1));
    month = num2str(datestt(2),'%.2d');
    dt     = num2str(datestt(3),'%.2d');
    %% Extract the obs and nav data
    gtime       = [obs_data.gtime]; % gps time
    [time_str,time_stp] = bounds(gtime);
    alltime = unique(gtime);
    if time_stp-time_str < 86400 && sum(diff(alltime)) < 86400;timebound = 86400;else;timebound = sum(diff(alltime));end
    ind_gtime   = nan(timebound,1);
    indt = 1;
    ind_gtime(1) = alltime(1);
    for t = 2:length(alltime) % match GPST
        dtime = ceil(alltime(t) - alltime(t-1));
        indt = indt+dtime;
        ind_gtime(indt) = alltime(t);
    end
    rawPRN      = [obs_data.PRN];
    uintA       = uint8(rawPRN);
    uintA       = reshape(uintA, [3, length(rawPRN)/3]);
    rawPRN      = char(uintA');
    gnsssys     = string(rawPRN(:,1));  % PRN
    gnssprn     = cellstr(string(rawPRN(:,2:3)));
    gnssprn     = str2double(gnssprn)'; % satellite constellation

    %% extract Frequency, P, L, (D and S) data
    freq = reshape([obs_data.freq],[40,length(obs_data)])'; %
    P    = reshape([obs_data.P],[10,length(obs_data)])';
    L    = reshape([obs_data.L],[10,length(obs_data)])';
    % D = reshape([obs_data.D],[10,length(obs_data)])';
    % S = reshape([obs_data.S],[10,length(obs_data)])';

    %% Calculate each system
    cons_gnss = unique(gnsssys);
    
    % cons_gnss(strncmp(cons_gnss, 'R',1)) = [];
    for sys = 1:length(cons_gnss)
        index_sys = logical((ismember(gnsssys,cons_gnss(sys))));
        prn_sys = unique(gnssprn(index_sys));
        sys_name = cons_gnss(sys);
        %% prepare matrix
        rawtecl   = nan(timebound,length(prn_sys));
        rawtecp   = nan(timebound,length(prn_sys));
        elev      = nan(timebound,length(prn_sys));
        azim      = nan(timebound,length(prn_sys));
        times     = nan(timebound,length(prn_sys));
        ipplat    = nan(timebound,length(prn_sys));
        ipplon    = nan(timebound,length(prn_sys));
        typepair  = repmat({'XXX'},2,length(prn_sys));
        PRN       = prn_sys;
        tind      = nan(timebound,length(prn_sys));
        %% read type of observation
        otype = obs_head.otype(startsWith(obs_head.otype,sys_name));
        otype = regexp(otype{:}, '\s+', 'split');
        otype = otype(2:end);
        [pairing, pindex, lindex] = obstype2pair(otype);  % find all combination
        if isempty(pairing)
            disp([char(sys_name) ' system: No paring '])
            continue
        end
        %% Choose paring
        best_pair = 0;
        Plength = nan(size(pairing,1),length(prn_sys));
        Llength = nan(size(pairing,1),length(prn_sys));
        for pind = 1:length(prn_sys)
            prn = prn_sys(pind);
            index_prn = logical((ismember(gnsssys,cons_gnss(sys))).*(ismember(gnssprn,prn))');
            gpst  = gtime(1,index_prn)';
            if isempty(gpst)
                continue;
            end
            for pr = 1:size(pairing,1)
                prm_p = P(index_prn,pindex(pr,:));
                P1 = prm_p(:,1);
                P2 = prm_p(:,2);
                prm_l = L(index_prn,lindex(pr,:));
                L1 = prm_l(:,1);
                L2 = prm_l(:,2);
                Plength(pr,pind) = sum(~isnan(P1+P2));
                Llength(pr,pind) = sum(~isnan(L1+L2));
            end
        end
        Lsum = sum(Llength')';
        [~, best_pair] = max(Lsum);
        % best_pair = 1;
        %% Calculate raw TEC (each PRN)
        for pind = 1:length(prn_sys)
            Tall = 1:timebound;
            prn = prn_sys(pind);
            index_prn = logical((ismember(gnsssys,cons_gnss(sys))).*(ismember(gnssprn,prn))');
            gpst  = gtime(1,index_prn)';
            if isempty(gpst)
                continue;
            end
            ind_time = logical(ismember(ind_gtime,gpst));
            tind(ind_time,pind) = Tall(ind_time);
            % frequency
            prm_f   = freq(index_prn,:);
            prm_f_C = prm_f(:,startsWith(otype,{'C','P'}));
            
            % Try to paring
            flag = 0;
            try
                all_freq      = prm_f_C(:,pindex(best_pair,:));
                f1 = all_freq(:,1);
                f2 = all_freq(:,2);
                prm_p = P(index_prn,pindex(best_pair,:));
                P1 = prm_p(:,1);
                P2 = prm_p(:,2);
                prm_l = L(index_prn,lindex(best_pair,:));
                L1 = prm_l(:,1);
                L2 = prm_l(:,2);
                typepair(:,pind) = pairing(best_pair,:);

                if sum(~isnan(P1+P2))<length(gpst)/2 || sum(~isnan(L1+L2))<length(gpst)/2
                    % disp(['SYS:' char(sys_name) ' PRN# ... ' num2str(prn) ' - Not enough pseudoranges pair:' char(pairing(pr,1)) '-' char(pairing(pr,2))])
                    continue
                end
                flag = 1;
            catch
                % disp([char(sys_name) ' system has enogth data of this pair:' char(pairing(pr,1)) '-' char(pairing(pr,2))])
                continue
            end
            if flag==0
                % disp(['SYS:' char(sys_name) ' PRN# ... ' num2str(prn) ' - Not enough pseudoranges'])
                continue
            end
            try
            % Coefficients
            coef_K = (f1.^2.*f2.^2./(40.3.*(f1.^2-f2.^2)*10.^16));
            % raw TEC calculation
            rawtecp(ind_time,pind) = coef_K.*(P2-P1);
            rawtecl(ind_time,pind) = coef_K.*(L1.*(c./f1) - L2.*(c./f2));
            catch
                continue
            end
            %% Calculate satellite position to calculate elevation angle
            ps = P1;
            if sys_name == 'R'     % GLONASS
                [satpos,~] = geph2sat(gpst,sys_name,prn,nav_data,ps);
            elseif sys_name == 'S' % SBAS
                [satpos,~] = seph2sat(gpst,sys_name,prn+19,nav_data,ps);
            else % GPS, GAL, QZS, BEI
                [satpos,~] = eph2sat(gpst,sys_name,prn,nav_data,ps);
            end
            if isempty(satpos);continue;end
            [elev(ind_time,pind),azim(ind_time,pind),...
                ipplat(ind_time,pind),ipplon(ind_time,pind)]= calelevation_ipp(satpos',refpos');
            times(ind_time,pind) = gpst;

        end
        %% elevation angle cut-off
        ind_mask                     = elev;
        ind_mask(ind_mask<elev_mask) = NaN;
        ind_mask(~isnan(ind_mask))   = 1;
        
        tind_m     = tind.*ind_mask;
        times_m    = times.*ind_mask;
        elev_m     = elev.*ind_mask;
        azim_m     = azim.*ind_mask;
        rawtecl_m  = rawtecl.*ind_mask;
        rawtecp_m  = rawtecp.*ind_mask;
        ipplat_m   = ipplat.*ind_mask;
        ipplon_m   = ipplon.*ind_mask;
        %% correct the TEC
        % Cycle slip correction
        tecl_m = cycleslipcorr_30(rawtecl_m,elev_m,tind_m,1:length(PRN));
        % tecl_roti = cycleslipcorrnew(rawtecl_m,elev_m,tind_m,1:length(PRN));

        % remove noisy
        % tecl_m = removenoisy(tecl_m);
        %% ROTI calculation
        % disp('Estimate ROTI ....') 
        % samp = obs_head.tinv;
        sf   = sqrt(1-(Re.*cosd(elev)./(Re+h)).^2); % mapping function
        roti = roticalculation(tecl_m,1:length(PRN),1);
        roti = roti.*sf;

        % window adjusted every length of nan/2
        tecl_b = windowshiftTEC(tecl_m,rawtecp_m);
        % Satellite DCB correction
        [stec_c,sdcb] = satdcbcor(tecl_b,dcb,coef_K,PRN,cons_gnss(sys),typepair);
        % receiver DCB correction
        
        [stec_r,vtec_r,rdcb]=rcvdcbcor(stec_c,coef_K,tind_m,sf);
        % outlinier correction
        stec    = outlinecorr(stec_r);
        vtec    = outlinecorr(vtec_r);
        % Using zero adjust TEC (Minimum TEC is Zero)
        tec_min = min(min(stec, [], 'omitnan'), [], 'omitnan');
        stec         =  stec  + tec_min;
        vtec         =  vtec  + tec_min;

        %% Save file
        systemname = sys_name;
        if sys_name == 'G'
            systemname = 'GPS';
        elseif sys_name == 'E'
            systemname = 'GAL';
        elseif sys_name == 'R'
            systemname = 'GLO';
        elseif sys_name == 'C'
            systemname = 'BDS';
        elseif sys_name == 'J'
            systemname = 'QZS';
        elseif sys_name == 'S'
            systemname = 'SBS';
        elseif sys_name == 'I'
            systemname = 'IRN';
        end
        eval([station_name '.' systemname '.date   = datestt;'])
        eval([station_name '.' systemname '.fpair  = typepair;'])
        eval([station_name '.' systemname '.PRN    = PRN;'])
        eval([station_name '.' systemname '.ind    = tind_m;'])
        eval([station_name '.' systemname '.times  = times_m;'])
        eval([station_name '.' systemname '.vtec   = vtec;'])
        eval([station_name '.' systemname '.stec   = stec;'])
        eval([station_name '.' systemname '.roti   = roti;'])
        eval([station_name '.' systemname '.ipplat = ipplat_m;'])
        eval([station_name '.' systemname '.ipplon = ipplon_m;'])
        eval([station_name '.' systemname '.elev   = elev_m;'])
        eval([station_name '.' systemname '.rdcb   = rdcb;'])
        eval([station_name '.' systemname '.sdcb   = sdcb;'])

        disp(['Finish ' systemname ' at ' station_name ' station'])
    end

    %% inter system biases correction
    % estimate inter-system bias using GPS as baseline
    % eval([station_name '= intersystembias(' station_name ');']);
    %% Save file
    eval([station_name '.z_rcvpos   = refpos;'])
    if ~isempty([S_path year]);mkdir([S_path year]);end
    if ~isempty([S_path year '\' doy]);mkdir([S_path year '\' doy]);end
    %filename = [S_path year '\' doy '\TECROTI_' doy '_' year month dt '_' station_name '.mat'];
    filename = [S_path outname '.mat'];
    save(filename,station_name)
    disp(['Complete to Calculate TEC at ' station_name ' station'])
    calstat{st,1} = station_name;
    calstat{st,2} = 'avialable';
    toc
	clearvars -except calstat date_s dates dcb doy dt mth R_path rnxstat S_path st yr
end


end