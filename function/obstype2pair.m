function [pairing, pindex, lindex] = obstype2pair(obstype)
% obstype [cell array]: header type
% ptype [char,string]: 'C' - code pseudorange, 'L' - carrier-phase pseudorange
typeC   = obstype(startsWith(obstype,'C')|startsWith(obstype,'P'));
typeL   = obstype(startsWith(obstype,'L'));
freq_C = typeC;
for i = 1:numel(typeC)
    f_C{i}    = typeC{i}(2:end); % Remove the first-second character
    freq_C{i} = typeC{i}(2);     % read frequency
end
freq_L = typeL;
for i = 1:numel(typeL)
    f_L{i}    = typeL{i}(2:end); % Remove the first-second character
    freq_L{i} = typeL{i}(2);     % read frequency
end
pairing   = nchoosek(typeC,2);
pairf_C   = nchoosek(f_C,2);
pairf_L   = nchoosek(f_L,2);
fall_C    = nchoosek(freq_C,2);
fall_L    = nchoosek(freq_L,2);
% remove same frequency
pairing(str2double(fall_C(:,1)) == str2double(fall_C(:,2)),:)=[];
pairf_C(str2double(fall_C(:,1)) == str2double(fall_C(:,2)),:)=[];
% pairf_L(str2double(fall_L(:,1)) == str2double(fall_L(:,2)),:)=[];

% defind index
pindex = false(size(pairing,1),length(f_C));
lindex = false(size(pairing,1),length(f_L));
ind    = [];
for j = 1:size(pairing,1)
    indexC = ismember(f_C,pairf_C(j,1))+ismember(f_C,pairf_C(j,2));
    indexL = ismember(f_L,pairf_C(j,1))+ismember(f_L,pairf_C(j,2)); % check avialable carrier-phase
    pindex(j,:) = logical(indexC);
    lindex(j,:) = logical(indexL);
    if sum(indexC)~=2 || sum(indexL) ~=2
        ind = [ind j];
    end
end
if ~isempty(ind) % remove pairing, which is not complete (need code and carrier)
    pairing(ind,:) = [];
    pindex(ind,:) = [];
    lindex(ind,:) = [];
end

% Select paring, including C1/C2 (BDS)
sl = logical(sum(ismember(pairing,typeC{1})'));
pairing = pairing(sl,:);
pindex  = pindex(sl,:);
lindex  = lindex(sl,:);


