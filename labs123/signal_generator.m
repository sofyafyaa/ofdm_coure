function Tx_Signal = signal_generator(OFDM_symbols, T_guard)

% Adding T_Guard cyclik prefix
TX_prefix = [OFDM_symbols(:, end-T_guard+1:end), OFDM_symbols];
% Stitching
Tx_Signal = reshape(TX_prefix.', 1, []);

end

