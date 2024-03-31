function RX_Signal_H = multipath(Tx_Signal, channel)

h = zeros(size(Tx_Signal));

for i = 1:1:size(channel(:,1), 1)
    h(channel(i,1)+1) = channel(i,2);
end

RX_Signal_H = conv(Tx_Signal, h, "same");

end

