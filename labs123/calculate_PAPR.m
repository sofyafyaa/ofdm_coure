function sign_PAPR = calculate_PAPR(RX_Sign, win)

sign_PAPR = zeros(1, length(RX_Sign)+1-win);

for it = 1 : length(RX_Sign)+1-win
    part = RX_Sign(it : it-1+win);
    sign_PAPR(it) = 10*log10(max(abs(part).^2)/mean(abs(part).^2));
end

end
