function [BER] = Error_check(Bit_Tx, Bit_Rx)

Error_vector = xor(Bit_Tx, Bit_Rx);

BER = sum(Error_vector)/length(Bit_Rx);

end

