function bits_rand = randomizer(bits, register)

bits_rand = zeros(size(bits));

for i = 1 : length(bits)
xorval = xor(register(end), register(end-1));
register =  circshift(register, 1);
register(1) = xorval;

bits_rand(1, i) = double(xor(bits(i), register(1)));
end

end

