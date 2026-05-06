function [satpos,satclk] = eph2sat(rcvsec,sys,nprn,data_nav,ps)
    % For calculate satellite parameters of GPS, GAL, QZS, BEI
    sys = char(sys);
    if sys=='G' 
        navall = data_nav.GPS;
    elseif sys=='E' 
        navall = data_nav.GAL;
    elseif sys=='J' 
        navall = data_nav.QZS;
    elseif sys=='C' 
        navall = data_nav.BEI;
    end
PRN = [navall.PRN];
%%%% Read Ephemeride %%%%
nav = navall(ismember(PRN,nprn));
if isempty(nav)
    disp(['SYS:' sys ' PRN# ... ' num2str(nprn) ' - No nav data'])
    satpos = [];
    satclk = [];
    return;
end
% Orbit Parameters
a       = [nav.A];          % Semi-major axis                       (m)              
e       = [nav.e];          % Eccentricity
w0      = [nav.omg];        % Argument of perigee                   (rad)
W0      = [nav.OMG0];       % Right ascension of ascending node     (rad)
Wdot    = [nav.OMGd];          % Rate of right ascension               (rad/sec)
i0      = [nav.i0];          % Inclination                           (rad)
idot    = [nav.idot];          % Rate of inclination                   (rad/sec)
M0      = [nav.M0];          % Mean anomaly                          (rad)
delta_n = [nav.deln];          % Mean motion rate                      (rad/sec)

% Correction coefficients
Cuc     = [nav.cuc];         % Argument of perigee (cos)             (rad) 
Cus     = [nav.cus];         % Argument of perigee (sine)            (rad)
Crc     = [nav.crc];         % Orbit radius        (cos)             (m)
Crs     = [nav.crs];         % Orbit radius        (sine)            (m)
Cic     = [nav.cic];         % Inclination         (cos)             (rad) 
Cis     = [nav.cis];         % Inclination         (sine)            (rad)

% Time
Toe     = [nav.toes];         % Time of Ephemeris                     (SOW : sec of GPS week)
GPS_week= [nav.week];         % GPS Week

Ttm     = [nav.ttr];         % Transmission time of message -604800  (SOW : sec of GPS week)
gpst    = [nav.time];
TIME    = gpst2time(gpst');


%  Year month day
Y       = TIME(:,1);          % Year     
MA      = TIME(:,2);          % Month
D       = TIME(:,3);          % Day of month
Hr      = TIME(:,4);              
m       = TIME(:,5);          
s       = TIME(:,6); 

% Clock
T0_bias = [nav.f0];          % Clock Bias                            (sec)
T0_drift= [nav.f1];          % Clock Drift                           (sec/sec)
T0_drate= [nav.f2];          % Clock Drift rate                      (sec/sec^2)
Tgd     = reshape([nav.tgd],[4,length(nav)])';         % Time Group delay                      (sec)
Tgd     = Tgd(:,1);

% Status
SV_health   = [nav.svh];     % SV Health
SV_accuracy = [nav.sva];     % SV Accuracy
L2_P_flag   = [nav.flag];     % L2 P data flag
L2_code     = [nav.code];     % Code on L2 channel
IODC        = [nav.iodc];     % Issue of Data, Clock
IODE        = [nav.iode];     % Issue of Data, Ephemeris

% Constant
c   = 299792458;
GM  = 3.986004418*10^14;        % Earth's universal gravitational parameter     (m^3/s^2)
We  = 7.2921151467*10^-5;       % earth angular velocity (IS-GPS)               (rad/sec)
F   = -4.442807633e-10;         % constant        (sec/(meter)1/2)

% == start calculate ==
% rcv time
rcvtime = gpst2time(rcvsec);

% calculate second of week (SOW)
gpst0 = [1980,1, 6,0,0,0]; % gps time reference
% gst0  = [1999,8,22,0,0,0]; % galileo system time reference
% bdt0  = [2006,1, 1,0,0,0]; % beidou time reference
tref0 = gpst0; 
% if sys == 'R';tref0 = gst0;We = 7.2921151467*10^-5;
% elseif sys == 'C';tref0 = bdt0;We = 7.292115*10^-5;
% end
rcvtime0 = [rcvtime(:,1),rcvtime(:,2),rcvtime(:,3), 0.*rcvtime(:,4),0.*rcvtime(:,5),0.*rcvtime(:,6)];
GPSW = fix((time2gpst(rcvtime0) - time2gpst(tref0))./(7*86400));

satpos = nan(size(rcvsec,1),3);
satclk = nan(size(rcvsec,1),1);



for ii = 1:size(rcvsec,1)

    % Calculation of second of the GPS Week (SOW)
    SOW = rcvsec(ii) - time2gpst(gpst0) - (GPSW(ii)*7*86400);

    % Find correct ephemerides
    [~,col] = min(abs(SOW-Toe));                     % Use closest Toe
    %[y,col] = max(find((SOW-Toe)>=0));              % Use last Toe (like GPS receiver do)


    %%%%% Calculate satellite position
    tr = ps(ii)/c;
    TOS   = SOW-tr;                                           % Expected Time             (SOW : sec of GPS week)

    Tk      = TOS - Toe(col);                                 % Time elaped since Toe     (SOW : sec of GPS week)

    MA       = M0(col) + (sqrt(GM/a(col)^3)+delta_n(col))*Tk;    % Mean anomaly at Tk 

    % Iterative solution for E 
    E_old = MA;
    dE = 1;
    count = 0;
    while (dE > 10^-12)
        if count > 10; break;else; count = count+1;end
        EA = MA + e(col)*sin(E_old);                                % Eccentric anomaly
        dE = abs(EA-E_old);
        E_old = EA;
    end

    TA = atan2(sqrt(1-e(col)^2)*sin(EA), cos(EA)-e(col));          % True anomaly

    W = W0(col) + (Wdot(col)-We)*Tk - (We*Toe(col));            % Right ascension of ascending node

    % Correction for orbital perturbations
    w = w0(col) + Cuc(col)*cos(2*(w0(col)+TA)) + Cus(col)*sin(2*(w0(col)+TA));                        % Argument of perigee
    r = a(col)*(1-e(col)*cos(EA)) + Crc(col)*cos(2*(w0(col)+TA)) + Crs(col)*sin(2*(w0(col)+TA));       % Radial distance
    i = i0(col) + idot(col)*Tk + Cic(col)*cos(2*(w0(col)+TA)) + Cis(col)*sin(2*(w0(col)+TA));         % Inclination

    satpos_in = [r*cos(TA) r*sin(TA) 0]';                  % Satellite position vector (Earth's center in inertial frame)

    % rotation matrix
    R = [cos(W)*cos(w)-sin(W)*sin(w)*cos(i) -cos(W)*sin(w)-sin(W)*cos(w)*cos(i)  sin(W)*sin(i);
         sin(W)*cos(w)+cos(W)*sin(w)*cos(i) -sin(W)*sin(w)+cos(W)*cos(w)*cos(i) -cos(W)*sin(i);
                   sin(w)*sin(i)                    cos(w)*sin(i)                      cos(i)];

    satpos(ii,:) = (R*satpos_in)';                               % Satellite position vector (ECEF)

    %%%% Clock error computation %%%%
    % 1. relative correction
    r_c = F*e(col)*sqrt(a(col))*sin(EA);
    % 2. SV clock correction
    t_sv = T0_bias(col) + T0_drift(col)*(Tk) + T0_drate(col)*(Tk^2) + r_c;

    satclk(ii) = t_sv-Tgd(col);
end

end

