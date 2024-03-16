function Rx_IQ = OFDM_Signal_Demod(Rx_Sign, N_fft, T_guard, N_carrier)

% Restitching
Rx_Frames = reshape(Rx_Sign, N_fft+T_guard, []).';

% Deletting T_Guard
Rx_Frames = Rx_Frames(:, T_guard+1 : end);

% Spec
Rx_Spec = fft(Rx_Frames, N_fft, 2);
Rx_Spec(abs(Rx_Spec)<(1e-13)) = 0;
Rx_Spec_reshape = Rx_Spec(:, 2 : N_carrier+1);
Rx_IQ = reshape(Rx_Spec_reshape.', 1, []);



end
