function [satpos,satclk] = geph2sat(rcvsec,sys,nprn,data_nav,ps)
    % For calculate satellite parameters of GLONASS
    sys = char(sys);
if sys ~='R' 
    error('geph2sat for GLONASS only')
end
navall = data_nav.GLO;
PRN = [navall.PRN];
% Constants
tstep = 60;            % integration step glonass ephemeris (s)

%%%% Read Ephemeride %%%%
nav = navall(ismember(PRN,nprn));
if isempty(nav)
    disp(['SYS:' sys ' PRN# ... ' num2str(nprn) ' - No nav data'])
    satpos = [];
    satclk = [];
    return;
end
% Time
Toe     = [nav.toe];         % Time of Ephemeris                     (SOW : sec of GPS week)

% Orbit Parameters
gpos = reshape([nav.pos],[3,length(nav)])';        % Coordinate in PZ-90
gvel = reshape([nav.vel],[3,length(nav)])';        % Velocity component in PZ-90
gacc = reshape([nav.acc],[3,length(nav)])';        % Moon and sun acceleration

% Clock
taun = [nav.taun]';       % SV clock offset
gamn = [nav.gamn]';       % SV relatie frequency offset

%%% Calculation
satpos = nan(size(rcvsec,1),3);
satclk = nan(size(rcvsec,1),1);
for ii = 1:size(rcvsec,1)
    % find closest time of ephemeris
    [~,col] = min(abs(rcvsec(ii)-Toe));
    c  = 299792458;
    tr = ps(ii)/c;
    T = rcvsec(ii)-Toe(col)-tr;
    X = zeros(6,1);
    X(1:3) = gpos(col,:);
    X(4:6) = gvel(col,:);
    T2 = T;
    while abs(T) > 1e-9
        tt = tstep;
        if T<0
            tt = -tstep;
        end
        if abs(T)<tstep
            tt=T;
        end
        % glonass position and velocity by numerical integration
        X = glorbit(tt,X,gacc(col,:));
        T = T-tt;
    end
    satpos(ii,:) = X(1:3);
    % Cal satellite clock bias
    for i = 1:2
        T2 = T2-(-taun(col,:)) + gamn(col,:)*T2;
    end
    satclk(ii) = (-taun(col,:)) + gamn(col,:)*T2;
end
