function [MER] = MER_my_func(IQ_RX, Constellation)

[Dictionary, ~] = constellation_func(Constellation);

IQ = zeros(1, length(IQ_RX));
IQerror = zeros(1, length(IQ_RX));

for itter1 = 1 : length(IQ_RX)

    err_all = IQ_RX(itter1) - Dictionary;

    [~, IQerror_idx] = min(abs(err_all));

    IQerror(itter1) = err_all(IQerror_idx);

    IQ(itter1) = Dictionary(IQerror_idx);
end

MER = 10.*log10(sum(abs(IQ).^2)./sum(abs(IQerror).^2));

end

