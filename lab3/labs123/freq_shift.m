function TX_Signal_shift = freq_shift(Tx_signal, Freq_Shift, N_fft, T_guard)

k = double(linspace(1, length(Tx_signal), length(Tx_signal))); 

TX_Signal_shift = Tx_signal .* exp(2j*double(pi)*k*double(Freq_Shift)/double(N_fft));

end