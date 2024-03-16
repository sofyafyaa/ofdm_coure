classdef Modulator < handle
    
    % Пропертис! Чтобы удобнее можно было наблюдать, что творится при
    % работе с классом
    properties
        Constellation; % Название созвездия
        Base_Constellation_Points; % Все символы и iq-точки созвездия
        Cells; % Кол-во точек созвездия
        QAM_Cells; % Кол-во IQ-компонент на выходе маппера
        Bit_Depth; % Кол-во бит, задающее точку созвездия
        File; % Путь до файла
        Input_Bit_Buffer; % Входной битовый поток
        Input_Symbols; % Входные символы
        IQ_Components; % Сформированные IQ-компоненты
        Output_Symbols; % Выходные символы
        Output_Bit_Buffer; % Выходные символы
        N_err; % Кол-во ошибочных символов
        BER; % Битовая ошибка (bit error rate)
        Power_Norm; % Коэффициент нормировки точек созвездия
    end

    % Магические заклинания
    methods
        % Функция - инициализатор класса. Задает имя до файла и параметры
        % выбранного в основной программе созвездия.
        function obj = Modulator(File, Constellation, QAM_Cells)
            if(nargin > 0)
                obj.File = File;
                obj.Constellation = Constellation;
                obj.QAM_Cells = QAM_Cells;
                switch obj.Constellation
                    case "BPSK"
                        obj.Bit_Depth = 1;
                        obj.Cells = 2;
                        obj.constellib(obj.Constellation);
                        obj.constellib(obj.Constellation);
                    case "QPSK"
                        obj.Bit_Depth = 2;
                        obj.Cells = 4;
                        obj.constellib(obj.Constellation);
                    case "16-QAM"
                        obj.Bit_Depth = 4;
                        obj.Cells = 16;
                        obj.constellib(obj.Constellation);
                    otherwise 
                        obj.Constellation = "BPSK";
                        obj.Bit_Depth = 1;
                        obj.Cells = 2;
                        obj.constellib(obj.Constellation);
                end              
            end
        end

        % Функция - созидатель битового потока из файла. Ахалай-махалай.
        function obj = file_reader(obj, filesize)
            fileID = fopen(obj.File,'r','b');
            bitstream = fread(fileID, filesize, 'ubit1'); % Считали QAM_Cells*Bit_Depth бит из файла
            fclose('all');
            obj.Input_Bit_Buffer = reshape(bitstream,1,[]);
            obj = obj.Input_Bit_Buffer;
        end

        % Функция-маппер. Сим-сялябим теперь и без больших свитчей!
        function obj = mapping(obj, inputbits)
            obj.Input_Symbols = reshape(inputbits, [obj.Bit_Depth size(inputbits, 2)/obj.Bit_Depth]);
            switch obj.Constellation
                case "BPSK"
                    for i = 1:1:size(obj.Input_Symbols, 2)
                        symbol = reshape(num2str(obj.Input_Symbols(:,i)),1,[]);
                        bit = obj.Base_Constellation_Points(symbol);
                        IQstream(i) = bit;
                    end
                case "QPSK"
                    for i = 1:1:size(obj.Input_Symbols, 2)
                        symbol = reshape(num2str(obj.Input_Symbols(:,i)),1,[]);
                        bit = obj.Base_Constellation_Points(symbol);
                        IQstream(i) = bit;
                    end
                case "16-QAM"
                    for i = 1:1:size(obj.Input_Symbols, 2)
                        symbol = reshape(num2str(obj.Input_Symbols(:,i)),1,[]);
                        bit = obj.Base_Constellation_Points(symbol);
                        IQstream(i) = bit;
                    end
                otherwise
                    for i = 1:1:size(obj.Input_Symbols, 2)
                        symbol = reshape(num2str(obj.Input_Symbols(:,i)),1,[]);
                        bit = obj.Base_Constellation_Points(symbol);
                        IQstream(i) = bit;
                    end
            end
        obj.IQ_Components = IQstream;
        obj = obj.IQ_Components;
        end

        % Функция-демаппер (и по совместительству - созидатель 
        % демодулированного потока битовых данных)
        function obj = demapping(obj, iq)
            switch obj.Constellation
                case "BPSK"
                    for i = 1:1:size(iq, 2)
                        symbstream(:, i) = obj.get_symbol(obj.get_min_diff(iq(i)));
                    end
                case "QPSK"
                    for i = 1:1:size(iq, 2)
                        symbstream(:, i) = obj.get_symbol(obj.get_min_diff(iq(i)));
                    end
               
                case "16-QAM"
                    for i = 1:1:size(iq, 2)
                        symbstream(:, i) = obj.get_symbol(obj.get_min_diff(iq(i)));
                    end
                otherwise
                    for i = 1:1:size(iq, 2)
                        symbstream(:, i) = obj.get_symbol(obj.get_min_diff(iq(i)));
                    end
            end
%         obj.IQ_Components = IQstream;
%         obj = obj.IQ_Components
        obj.Output_Symbols = symbstream;
        obj.Output_Bit_Buffer = reshape(symbstream, 1, []);
        obj = obj.Output_Bit_Buffer;
        end 

        % Проверка на лоха (зачеркнуто) наличие ошибочных бит
        % в переданном сообщении
        function obj = error_check(obj, tx_bitstream, rx_bitstream)
            obj.N_err = sum(xor(tx_bitstream, rx_bitstream));
            N_bits = size(tx_bitstream, 2);
            obj.BER = obj.N_err / N_bits;
            obj = obj.BER;
        end

        % Функция для расчета коэффициента нормировки созвездия по средней
        % мощности
        function obj = norm_constellation(obj, iq)
            iq = values(iq);
            energy = 0;
            for i = 1:size(iq, 2)
                energy = energy + (cell2mat(iq(i))*conj(cell2mat(iq(i))))/size(iq, 2);
            end
            obj.Power_Norm = sqrt(energy);
            obj = obj.Power_Norm;
        end

        % Функция - созидатель объекта с информацией о точках заданного
        % созвездия (объект Base_Constellation_Points с ключами и значениями)
        function obj = constellib(obj, constellation)
            switch constellation
                case "BPSK"
                    cells = containers.Map({'0' '1'},{complex(-1+0j) complex(1+0j)});
                    obj.Base_Constellation_Points = cells;
                case "QPSK"
                    cells = containers.Map({'00' '01' '10' '11'}, ...
                        {-1-1j -1+1j 1-1j 1+1j});
                    obj.Base_Constellation_Points = cells;
                case "16-QAM"
                    cells = containers.Map({'0000' '0001' '0010' '0011' ...
                        '0100' '0101' '0110' '0111'...
                        '1000' '1001' '1010' '1011'...
                        '1100' '1101' '1110' '1111'},...
                        {-3+3j -3+1j -3-3j -3-1j...
                        -1+3j -1+1j -1-3j -1-1j...
                        3+3j 3+1j 3-3j 3-1j...
                        1+3j 1+1j 1-3j 1-1j});
                    obj.Base_Constellation_Points = cells;
            end
        end


%       Функция, которая берет норму и для минимальной векторной разности
%       сопоставляет принятой iq-комп. наиб. вероятную компоненту
%       из заданного созвездия
        function obj = get_min_diff(obj, iq)
            constvalues = cell2mat(values(obj.Base_Constellation_Points));
            for i = 1:1:size(constvalues, 2)
                diffs(i) = norm(constvalues(i) - iq);
            end
            [M, K] = min(diffs);
            iq_norm = constvalues(K);
            obj = iq_norm; 
        end        

%       Функция, которая вытаскивает из Base_Constellation_Points двоичный 
%       символ по его значению наиболее (после get_min_diff) вероятной iq-комп-те 
        function obj = get_symbol(obj, iq_norm)
            value = cellfun(@(x)isequal(x,iq_norm),...
                values(obj.Base_Constellation_Points));
            extractkeys = keys(obj.Base_Constellation_Points);
            symbol = str2num(cell2mat(strread(char(extractkeys(value)),'%1s')));
            obj = symbol;
        end
        
       
    end
end
