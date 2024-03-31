function [IQ] = mapping(Bit_Tx, Constellation)
% Make the different dictionary for BPSK, QPSK, 8PSK, 16QAM constellations
% calculate the Bit_depth for each contellation

[Dictionary, Bit_depth_Dict] = constellation_func(Constellation);

% write  the function of mapping from bit vector to IQ vector

IQ_length = length(Bit_Tx)/Bit_depth_Dict;

IQ_length = round(IQ_length, 0, "TieBreaker", "minusinf");

Bit_Tx((IQ_length*Bit_depth_Dict+1):end) = [];

Bit_Tx = Bit_Tx';

%index = bit2int(Bit_Tx, Bit_depth_Dict);

IQ = Dictionary(bit2int(Bit_Tx, Bit_depth_Dict) + 1);

end