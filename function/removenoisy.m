function stecn = removenoisy(stec)
% remove too noisy stec
stecn = stec;
noise_all = [];
for pn = 1:size(stec,2)
    check = diff(stec(:,pn));
    check(isnan(check)) = [];
    if ~isempty(check)
        varcheck = var(check);  
        if varcheck > 10^-3
            stecn(:,pn) = nan;
        end
    end
end