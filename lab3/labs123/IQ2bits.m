function [bits_num] = IQ2bits(IQ_num, constellation)
[~, const_depth] = constellation_func(constellation);
bits_num = IQ_num * const_depth;
end

