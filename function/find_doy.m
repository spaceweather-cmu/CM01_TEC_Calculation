function [Year,doy] = find_doy(d)
date = datevec(d);
D1 = date(:,1:3);
D2 = D1;
D2(:,2:3) = 0;
ydoy = cat(2, D1(:,1), datenum(D1) - datenum(D2));
% mth = D1(2);
% Year = num2str(ydoy(1,1));
% doy = num2str(ydoy(1,2),'%.3d');
Year = ydoy(1,1);
doy  = ydoy(1,2);
end