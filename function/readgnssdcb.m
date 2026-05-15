function DCB = readgnssdcb(DCB_file_gz, DCB_path)
cd(DCB_path)
% Download GNSS DCB from cddis website [ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/products/mgex/dcb/]
% provided by Chinese Academy of Sciences (CAS) or GeoForschungsZentrum Potsdam (GFZ)
% and read DCB

%% 2. decompress DCB file
gunzip(DCB_file_gz);
[~,DCB_name,~] = fileparts(DCB_file_gz);
%% Read DCB file
fileID = fopen(DCB_name,"r");

lineNumber = 0;
while ~feof(fileID)
    line = fgetl(fileID);
    lineNumber = lineNumber + 1;
    
    if startsWith(line, "*BIAS SVN_")
        fprintf('Found at line %d: %s\n', lineNumber, line);
        idx_header = lineNumber;
        break; % Stop after finding the first instance
    end
end

while ~feof(fileID)
    line = fgetl(fileID);
    lineNumber = lineNumber + 1;
    
    if startsWith(line, "-BIAS/SOLUTION")
        fprintf('Found at line %d: %s\n', lineNumber, line);
        idx_end = lineNumber-1;
        break; % Stop after finding the first instance
    end
end

frewind(fileID)
C = textscan(fileID,"%4s%6s%4s%5s%9s%5s%16s%15s%3s%24f%12f",idx_end-idx_header,"HeaderLines",idx_header,"MultipleDelimsAsOne",false,"Whitespace",'','CollectOutput',true);
C{1} = strtrim(C{1});
% C{3} = strtrim(C{3});
fclose(fileID);

%% find GNSS station index
idx = find(~ismissing(C{1}(:,4)),1)-1;

%% find PRN
% sys = C{1}(:,3);
% prn = C{2};
sys = extractBefore(C{1}(1:idx,3),2);
prn = str2double(extractAfter(C{1}(1:idx,3),1));

%% OBS1 and OBS2
OBS1 = C{1}(1:idx,5);
OBS2 = C{1}(1:idx,6);

%% raw DCB
rDCB = C{2}(1:idx,1);

%% map to the results
sat_list = ["GPS","GLO","GAL","BDS","QZS"];
sat_char = ['G','R','E','C','J'];

for i = 1:length(sat_list)
    mask = find(strcmp(sys, sat_char(i)));
    if ~isempty(mask)
        DCB.(sat_list(i)).OBS1 = OBS1(mask);
        DCB.(sat_list(i)).OBS2 = OBS2(mask);
        DCB.(sat_list(i)).PRN  = prn(mask);
        DCB.(sat_list(i)).val  = rDCB(mask);
    end
end

cd("..")