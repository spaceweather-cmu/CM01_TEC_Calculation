function xdot = deq(X,acc)
% glonass orbit differential equations

% constants
xdot = X.*0;
Re_glo =   6378136.0;     % radius of earth (m)
We = 7.292115e-5;         % earth angular velocity (rad/s) - GLONASS
j2_glo = 1.0826257e-3;    % 2nd zonal harmonic of geopot
Mu_glo = 3.9860044e14;    % gravitational constant
omg2 = We*We;
r2 = dot(X(1:3),X(1:3));
r3 = r2*sqrt(r2);

if r2<=0
    xdot = xdot*0;
    disp("Glonass orbit diff equation error")
    return;
end

a = 1.5 * j2_glo * Mu_glo * Re_glo*Re_glo / r2 / r3;   % 3/2*J2*mu*Ae^2/r^5
b = 5.0 * X(3) * X(3) / r2;                           % 5*z^2/r^2
c = -Mu_glo/r3 - a*(1-b);                             % -mu/r^3-a(1-b)
xdot(1) = X(4);
xdot(2) = X(5);
xdot(3) = X(6);
xdot(4) = (c + omg2)*X(1) + 2*We*X(5) + acc(1);
xdot(5) = (c + omg2)*X(2) - 2*We*X(4) + acc(2);
xdot(6) = (c - 2*a) *X(3) + acc(3);
end