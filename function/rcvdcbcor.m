function [stec_c,vtec_c,rdcb]=rcvdcbcor(stec,K,tind,sf)
% Output: stec_c: stec without DCBs [TECu]
%         vtec_c: vtec without DCBs [TECu]
%         rdcb: receiver DCB [ns]
% Input: stec: stec with receiver DCB [TECu]
%        K: coeficients
%        tind: index of times
%        sf: slant factor 

% disp('Remove receiver bias ....')
% constants
stp = -100;      % Start
edp = 100;       % Ending
sts = 0.1;       % Step

K = K(1);
tind(isnan(tind))=[];
int = unique(tind);
inv = round(length(int)/1440);
short_stec = stec(int(1:inv:end),:);  % downsampling to 1 min/5 min
short_sf   = sf(int(1:inv:end),:);    % downsampling to 1 min/5 min
br = [stp:sts:edp];
flac = 1;
c  = 299792458;             %   light speed = 299792458 m/s
for loop=0:5
    if ~flac
        br = rdcb-(sts/(10^(loop-1))):sts/(10^loop):rdcb+(sts/(10^(loop-1)));
    end
    std_vtec = nan(length(br),1);
    for bri = 1:length(br)
        %=========== remove receiver bias
%         Br = br*(c*(f1^2*f2^2/(A*(f1^2-f2^2)*10^16)))*(10^-9);
        Br = br.*(10^-9).*c.*K;
        %=========== convert to VTEC
        VTEC_no_sat_dcb  = (short_stec - Br(bri)).*short_sf;
        %=========== determine standard deviation
        VTEC_std           = std(VTEC_no_sat_dcb',"omitnan");
        std_vtec(bri)      = sum(VTEC_std',"omitnan");
    end
    %========== find minimum value
    [std_vtec,Br] = min(std_vtec(:));
    [Y,Z] = ind2sub([size(std_vtec,1) size(std_vtec,2)],Br);
    %========== choose receiver bias
    rdcb = br(Y,Z); % ns
    flac = 0;
end
% if rdcb exceed the limit, we will define rcv bias as zero.
if abs(rdcb)>=edp;rdcb = 0; end
stec_c = stec -  ones(size(stec))*diag(rdcb'.*(10^-9).*c.*K);
% stec_c = stec -  ones(size(stec))*diag(rdcb');
vtec_c = stec_c.*sf;
