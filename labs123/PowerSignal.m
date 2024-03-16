function P_Signal = PowerSignal(Signal)
% Calculate average Power of Signal

S_real2 = Signal .* conj(Signal);
P_Signal = sum(S_real2) / length(Signal);

end

