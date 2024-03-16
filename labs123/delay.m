function TX_Signal_delay = delay(TX_Signal, Time_delay)

TX_Signal_delay = [zeros(1, Time_delay), TX_Signal(1:end-Time_delay)];

end

