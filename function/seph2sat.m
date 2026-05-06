function [satpos,satclk] = seph2sat(rcvsec,sys,nprn,data_nav,ps)
    % For calculate satellite parameters of GLONASS
    sys = char(sys);
if sys ~='S' 
    error('seph2sat for SBAS only')
end
navall = data_nav.SBS;
PRN = [navall.PRN];

%%%% Read Ephemeride %%%%
nav = navall(ismember(PRN,nprn));
if isempty(nav)
    disp(['SYS:' sys ' PRN# ... ' num2str(nprn+100) ' - No nav data'])
    satpos = [];
    satclk = [];
    return;
end
% Time
Toe     = [nav.t0];         % Time of Ephemeris                    

% Orbit Parameters
gpos = reshape([nav.pos],[3,length(nav)])';        % Coordinate in PZ-90
gvel = reshape([nav.vel],[3,length(nav)])';        % Velocity component in PZ-90
gacc = reshape([nav.acc],[3,length(nav)])';        % Moon and sun acceleration

% Clock
af0 = [nav.af0]';       % SV clock offset
af1 = [nav.af1]';       % SV relatie frequency offset

%%% Calculation
satpos = nan(size(rcvsec,1),3);
satclk = nan(size(rcvsec,1),1);
for ii = 1:size(rcvsec,1)
    % find closest time of ephemeris
    [~,col] = min(abs(rcvsec(ii)-Toe));
    c  = 299792458;
    tr = ps(ii)/c;
    T = rcvsec(ii)-Toe(col)-tr;
    T2 = T;
    X = zeros(9,1);
    X(1:3) = gpos(col,:);
    X(4:6) = gvel(col,:);
    X(7:9) = gacc(col,:);
    satpos(ii,:) = X(1:3) + X(4:6).*T + X(7:9).*T.*T/2;
    % Cal satellite clock bias
    for i = 1:2
        T2 = T2 - af0(col,:) + af1(col,:)*T2;
    end
    satclk(ii) = af0(col,:) + af1(col,:)*T2;
end
