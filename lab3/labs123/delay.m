function TX_Signal_delay = delay(TX_Signal, Time_delay)

Signal_idx = 1 + Time_delay : 

TX_Signal_without_T_guard = TX_Signal(Signal_idx)

TX_Signal_delay = [TX_Signal(:, Time_delay:end) zeros(1, Time_delay-1)];

end

