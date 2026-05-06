function SOD = gpst2sod(gpst)

% check size
[ln,lp] = size(gpst);
SOD = nan(ln,lp);

for i = 1:lp
    Timing = gpst2time(gpst(:,i));
    SOD(:,i)    =  Timing(:,4).*3600 +  Timing(:,5).*60 + Timing(:,6);
end