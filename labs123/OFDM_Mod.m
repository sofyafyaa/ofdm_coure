function [Tx_OFDM] = ofdm_modulator(IQ_points, N_fft, N_carrier, ...
                                    OFDM_symb)

TX_IQ_frame = reshape(IQ_points, [N_carrier, OFDM_symb]).';

TX_IQ_frame = [zeros(OFDM_symb, 1), TX_IQ_frame];

Tx_OFDM = ifft(TX_IQ_frame, N_fft, 2);

end

