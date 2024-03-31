function [Bit] = demapping(IQ_RX, Constellation, IF_SOFT, SNR)
% Make the different dictionary for BPSK, QPSK, 8PSK, 16QAM constellations
% calculate the Bit_depth for each contellation

[Dictionary, Bit_depth_Dict] = constellation_func(Constellation);

if IF_SOFT == 0
    % write  the function of mapping from IQ vector to bit vector
    Bit = zeros(1, length(IQ_RX));
    
    for itter1 = 1 : length(IQ_RX)
        t = IQ_RX(itter1) - Dictionary;
        [~, idx_min] = min(abs(t));
        Bit(itter1) = idx_min-1;
    end
        Bit = int2bit(Bit, Bit_depth_Dict);
        Bit = reshape(Bit, [], 1);
        Bit = Bit';
else
    N0 = (sum(IQ_RX .* conj(IQ_RX)) / length(IQ_RX)) / (10.^(SNR/10));
    switch (Bit_depth_Dict)
        case 1
            Bit = log(exp((-(abs(IQ_RX-1)).^2)/N0) / ...
                      exp((-(abs(IQ_RX+1)).^2)/N0));

        case 2
            Bit = zeros(length(IQ_RX)*2, 1, 'double');
            Bit(1:2:end) = log( ...
                (exp(-(abs(IQ_RX(:) - Dictionary(1)).^2 / N0)) + exp(-(abs(IQ_RX(:) - Dictionary(2)).^2 / N0))) ./ ...
                (exp(-(abs(IQ_RX(:) - Dictionary(3)).^2 / N0)) + exp(-(abs(IQ_RX(:) - Dictionary(4)).^2 / N0))) ...
            );

            Bit(2:2:end) = log( ...
                (exp(-(abs(IQ_RX(:) - Dictionary(1)).^2 / N0)) + exp(-(abs(IQ_RX(:) - Dictionary(3)).^2 / N0))) ./ ...
                (exp(-(abs(IQ_RX(:) - Dictionary(2)).^2 / N0)) + exp(-(abs(IQ_RX(:) - Dictionary(4)).^2 / N0))) ...
            );

        case 3
            Bit = zeros(length(IQ_RX)*3, 1, 'double');

            % FIRST BIT
            nom = 0;
            for ind_nom = [1, 2, 3, 4]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [5, 6, 7, 8]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(1:3:end) = log(nom ./ denom);

            % SECOND BIT
            nom = 0;
            for ind_nom = [1, 2, 5, 6]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [3, 4, 7, 8]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(2:3:end) = log(nom ./ denom);

            % THIRD BIT
            nom = 0;
            for ind_nom = [1, 3, 5, 7]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [2, 4, 6, 8]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(3:3:end) = log(nom ./ denom);

        case 4
            Bit = zeros(length(IQ_RX)*4, 1, 'double');

            % FIRST BIT
            nom = 0;
            for ind_nom = [1, 2, 3, 4, 5, 6, 7]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [8, 9, 10, 11, 12, 13, 14, 15, 16]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(1:4:end) = log(nom ./ denom);

            % SECOND BIT
            nom = 0;
            for ind_nom = [1, 2, 3, 4, 9, 10, 11, 12]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [5, 6, 7, 8, 13, 14, 15, 16]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(2:4:end) = log(nom ./ denom);

            % THIRD BIT
            nom = 0;
            for ind_nom = [1, 2, 5, 6, 9, 10, 13, 14]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [3, 4, 7, 8, 11, 12, 15, 16]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(3:4:end) = log(nom ./ denom);

            % FOURTH BIT
            nom = 0;
            for ind_nom = [1, 3, 5, 7, 9, 11, 13, 15]
                nom = nom + exp(-(abs(IQ_RX(:) - Dictionary(ind_nom)).^2/N0));                                                    
            end
            denom = 0;
            for ind_denom = [2, 4, 6, 8, 10, 12, 14, 16]
                denom = denom + exp(-(abs(IQ_RX(:) - Dictionary(ind_denom)).^2/N0));                                                    
            end           
            Bit(4:4:end) = log(nom ./ denom);
    end
end

