function ep = gpst2time(gpst)
% input gpstime size(length, gpst)
% output ctime = [year month day hour min sec decimal_sec]

[ln,chk] = size(gpst);
if chk ~= 1
    ep = 0;
    disp('Wrong matrix shape cannot epoch...')
    return
end

% 
mday = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,...
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,...
		31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,...
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

% leap year if year%4==0 in 1901-2099
tsec = mod(gpst(:,1),1);
gpst(:,1) = gpst(:,1)-tsec;
days = floor(gpst(:,1) ./ 86400);
sec = gpst(:,1) - (days .* 86400);
day = mod(days,1461);
ep = nan(ln,6);
for i = 1:ln
    for mon = 1:48   
        if day(i) >= mday(mon)
            day(i) = day(i) - mday(mon);
        else
            break;
        end
    end
    ep(i,1) = 1970 + floor(days(i) / 1461) * 4 + floor(mon / 12);
    ep(i,2) = mod(mon,12);
    if ep(i,2) ==0 % December
        ep(i,1) = ep(i,1)-1;
        ep(i,2) = 12;
    end
    ep(i,3) = day(i) + 1;
    ep(i,4) = floor(sec(i) / 3600);
    ep(i,5) = floor(mod(sec(i),3600) / 60);
    ep(i,6) = mod(sec(i),60) + tsec(i);

end