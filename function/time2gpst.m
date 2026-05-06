function gpst = time2gpst(ctime)
% input: ctime matrix >> size(length, [year, month, date, hr, min, sec])
% output: gps time
[ln,chk] = size(ctime);
if chk ~= 6
    if ln == 6 && chk == 1
        gpst = 0; disp('Please transpost input...')
        return
    end
    gpst = 0;
    disp('Wrong matrix shape cannot cal gps time...')
    return
end

doy = [1,32,60,91,121,152,182,213,244,274,305,335];
year = ctime(:,1);
mon  = ctime(:,2);
day  = ctime(:,3);
hr  = floor(ctime(:,4));
min = floor(ctime(:,5));
sec = floor(ctime(:,6));

if (year(1)<1970)||(2099<year(1))||(mon(1)<1)||(12<mon(1))
    gpst = 0;
    return
end
gpst = nan(ln,1);
for i = 1:ln
    if mod(year(i),4) == 0 && mon(i)>=3
        b = 1;
    else
        b = 0;
    end
    % leap year if year%4==0 in 1901-2099
    days = ((year(i)-1970)*365) + fix((year(i)-1969)/4) + doy(mon(i)) + day(i) -2 + b;
    gpst(i,1) = days*86400 + hr(i)*3600 + min(i)*60 + sec(i);
end