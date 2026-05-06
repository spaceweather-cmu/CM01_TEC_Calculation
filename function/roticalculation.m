function ROTI_sec = roticalculation(STECl,PRNall,samp)
%{
 ========================================
 ROTI calculation (calculate every second)
 ========================================
 
 Description - Calculate Rate Of TEC Index (ROTI) 
 === input  ====
 STECl - Slant TEC that is calculated by using carrier-phase
 PRNall - Satellite index
 samp - sampling rate [min]
 === output ====
 ROTI  - Rate Of TEC Index
%}
ROTI_sec = nan(size(STECl));
for PRN = PRNall
    % interpolation
    STEC_sec = STECl(:,PRN);  
    ST = find(~isnan(STEC_sec(:)));
    flag = find((diff(ST))>1 & (diff(ST))<=300); % flag nan value
    if ~isempty(flag)
        for d = 1:length(flag)
            x = [1,length(STEC_sec(ST(flag(d)):ST(flag(d)+1)))];    % Define start/stop epoch
            v = [STEC_sec(ST(flag(d))),STEC_sec(ST(flag(d)+1))];    % Define start/stop data
            xq = 1:length(STEC_sec(ST(flag(d)):ST(flag(d)+1)));     % Define interpolated epoch
            STEC_M = interp1(x,v,xq,'linear','extrap');             % Interpolation 1D
        
            STEC_sec(ST(flag(d)):ST(flag(d)+1)) = STEC_M;
        end
    end
    
    % downsampling STEC and choose 5 values
    for T = (samp*60*5):length(STEC_sec) 
        if isnan(STEC_sec(T))
            ROTI_sec(T,PRN) = nan;
        else
            STEC_ds = STEC_sec((T-(samp*60*5))+1:samp*60:T);
            % Calculate different STEC
            ROT                = diff(STEC_ds)/samp;
            % ROT(length(ROT)+1) = NaN;
            % ROTI(ROT==0)       = NaN;
            % Calculate standard deviation
            ROTI_sec(T,PRN)    = std(ROT,"omitnan");
        end
    end
end