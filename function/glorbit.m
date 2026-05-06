function Xout = glorbit(dt,Xin,acc)
% glonass position and velocity by numerical integration

k1 = deq(Xin',acc);
w = Xin + k1'.*dt/2;

k2 = deq(w',acc);
w = Xin + k2'.*dt/2;

k3 = deq(w',acc);
w = Xin + k3'.*dt;

k4 = deq(w',acc);

Xout = Xin + (k1' + 2.*k2' + 2.*k3' + k4').*dt/6;
