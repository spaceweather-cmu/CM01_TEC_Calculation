function [elev,azi,ipplat,ipplon] = calelevation_ipp(satpos,xyz)
% Calculate elevation angle from satellite
%           and IPP position
% Inputs: 
%        satpos = Satellite position
%        xyz    = user position
% Outputs:
%       elevation_angle - Elevation angle
%       azi             - Azimute
%       ipplat          - IPP latitude
%       ipplon          - IPP longitude
%% 
Re           = 6371.009*10^3;                   %   The mean radius of the Earth (6371.009 km)
h            = 350*10^3;                        %   IPP height

enu = xyz2enu(satpos,xyz);                                      % convert to ENU
user_lla     = xyz2lla(xyz(1),xyz(2),xyz(3));                    % USER Lat Long Height
xyz_lla      = xyz2lla(satpos(1,:),satpos(2,:),satpos(3,:));     % Sate Lat Long Height
azi  = atan2(enu(1,:),enu(2,:)).*180/pi;
elev = atan2(enu(3,:),sqrt(enu(1,:).^2+enu(2,:).^2))*180/pi;
% elev = asin(enu(3,:)).*180/pi;

% Lat   = user_lla(1);
% Lon   = user_lla(2);
% Lat_s = xyz_lla(1);
% Lon_s = xyz_lla(2);
% R = [-sind(Lon)                cosd(Lon)                0;...
%      -sind(Lat)*cosd(Lon) -sind(Lat)*sind(Lon)  cosd(Lat);...
%      cosd(Lat)*cosd(Lon)   cosd(Lat)*sind(Lon)  sind(Lat)];
% Rs = [satpos(1,:)-xyz(1);satpos(2,:)-xyz(2);satpos(3,:)-xyz(3)]; % relative position
% RL = (R*Rs)'; % lla2enu
% Xl = RL(:,1);
% Yl = RL(:,2);
% Zl = RL(:,3);
% 
% elev = atan2(Zl,sqrt(Xl.^2+Yl.^2))*180/pi;
% % azi = atan2(cos(Lat_s) .* sin(Lon_s-Lon), cos(Lat) .* sin(Lat_s) - sin(Lat) .* cos(Lat_s) .* cos(Lon_s-Lon));
% azi = atan2(Xl,Yl)*180/pi;
%% IPP calculation
psir = 90-elev-asind(Re*cosd(elev)/(Re+h));
ipplat  = user_lla(1) + psir.*cosd(azi);
ipplon  = user_lla(2) + psir.*sind(azi)./cosd(ipplat);

end