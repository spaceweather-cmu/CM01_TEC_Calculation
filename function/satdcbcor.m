function [stec_c,satdcbs] = satdcbcor(stec,dcb,K,prn,sys,pair)

% constants
c = 299792458;  

% check system
if sys == 'G' % GPS
    DCBs = dcb.GPS;
elseif sys == 'R'
    DCBs = dcb.GLO;
elseif sys == 'E'
    DCBs = dcb.GAL;
elseif sys == 'C'
    DCBs = dcb.BDS;
elseif sys == 'J'
    DCBs = dcb.QZS;
else
    disp('No DCB information')
    stec_c = stec;
    satdcbs = prn.*0;
    return;
end
% Pairing
stec_c    = stec;
satdcbs   = prn.*0;
allPRNDCB = unique(DCBs.PRN);
for p = 1:length(prn)
    index     = logical(ismember(DCBs.OBS1,pair(1,p)).*ismember(DCBs.OBS2,pair(2,p)).*ismember(DCBs.PRN,prn(p)));
    if sum(index)==0
        inds   = find((DCBs.PRN == prn(p)), 1);
        dcbval = DCBs.val(inds);
        if isempty(dcbval)
            dcbval = 0;
        end
    else
        dcbval = DCBs.val(index);
    end
    satdcb      = dcbval*K(1)*c* 10^-9;
    stec_c(:,p) = stec(:,p) + satdcb;
    satdcbs(p)  = satdcb;
end
% 
% % for j = 1:size(pair,2)
% %     index
% % end
% index     = logical(ismember(DCBs.OBS1,pair(1,:)).*ismember(DCBs.OBS2,pair(2,:)).*ismember(DCBs.PRN,prn));
% dcb_prn   = DCBs.PRN(index);
% out_ind   = allPRNDCB(~ismember(allPRNDCB,dcb_prn));
% % match the other pair, if no exist
% if ~isempty(out_ind)
%     for i = 1:length(out_ind)
%         inds = find((DCBs.PRN == out_ind(i)), 1);
%         if ~isempty(inds)
%             index(inds) = 1;
%         end
%     end
% end
% 
% dcb_val   = DCBs.val(index);
% dcb_prn   = DCBs.PRN(index);
% satdcbs = dcb_prn.*0;
% for p = 1:length(prn)
%     n_prn = prn(p);
%     n_index = ismember(dcb_prn,n_prn);
%     if ~n_index
%         continue;
%     end
%     val         = dcb_val(n_index);
%     satdcb      = val*K(1)*c* 10^-9;
%     stec_c(:,p) = stec(:,p) + satdcb;
%     satdcbs(p)  = satdcb;
% end