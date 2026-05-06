function mat2csv_patresult(matfilename,s_path,outname)


% s_path = 'E:\OneDrive\00-Work\00-Research-Program\TEC-calculation-30s\Results\csv\';

matfile = load(matfilename);
station = fieldnames(matfile);
station = station{1,1};
% [SOD,sys,PRN,STEC,VTEC,ROTI]
eval(['data = matfile.' station ';'])
fdata = fieldnames(data);
date = data.GPS.date;
year = num2str(date(1));
mth  = num2str(date(2),'%.2d');
dt   = num2str(date(3),'%.2d');

for sys = 1:length(fdata)-1
    eval(['subdata = data.' fdata{sys,1} ';'])
    
    time = subdata.ind;
    time(isnan(time))= [];
    SOD = unique(time)';
    
    stec = subdata.stec(SOD,:);
    vtec = subdata.vtec(SOD,:);
    roti = subdata.roti(SOD,:);
    ipplat = subdata.ipplat(SOD,:);
    ipplon = subdata.ipplon(SOD,:);
    nPRN = ones(length(SOD), 1).*size(stec,2);
    system = repmat(fdata{sys,1}, length(SOD), 1);
    T = table(system,SOD,nPRN,vtec,stec,roti,ipplat,ipplon);
    %outputFilename = [s_path station '_' fdata{sys,1} '_' year mth dt '.csv'];
    outputFilename = [s_path outname '_' fdata{sys,1} '.csv'];
    writetable(T, outputFilename);
end

