classdef Scrambler < handle
    
    % Пропертис! Чтобы удобнее можно было наблюдать, что творится при
    % работе с классом
    properties
        InputSeq; % Входная последовательность
        Register = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; % Начальное состояние регистра 
    end

    % Магические заклинания
    methods        
        % Функция - инициализатор класса. Задает параметры РСЛОС.
        function obj = Scrambler(InitSeq)
             if(nargin > 0)
                obj.Register = InitSeq;
             end
        end

        % Функции для рандомизации/дерандомизации битового потока
        function obj = LFSR(obj, InputSeq, InitSeq)
            obj.Register = InitSeq;
            for i = 1:1:size(InputSeq, 2)
                xorval = xor(obj.Register(end),obj.Register(end-1));
                obj.Register =  circshift(obj.Register, 1);
                obj.Register(1) = xorval;
                OutputSeq(i) = double(xor(InputSeq(i), obj.Register(1)));
            end
            obj = OutputSeq;
        end

        function obj = randomizer(obj, InputSeq, InitSeq)
            obj.InputSeq = InputSeq;
            obj.Register = InitSeq;
            obj = obj.LFSR(obj.InputSeq, obj.Register);
        end

        function obj = derandomizer(obj, InputSeq, InitSeq)
            obj.InputSeq = InputSeq;
            obj.Register = InitSeq;
            obj = obj.LFSR(obj.InputSeq, obj.Register);
        end

        function obj = CCDF(obj, signal1, signal2, window)
            len1 = length(signal1);
            len2 = length(signal2);
            PAPR = 0:0.01:35;
            measPAPR1 = obj.PAPR(signal1, len1, window);
            measPAPR2 = obj.PAPR(signal2, len2, window);


            for i = 1:length(PAPR)
                CCDF1(i) = length(find(measPAPR1 >= PAPR(i)))/len1;
                CCDF2(i) = length(find(measPAPR2 >= PAPR(i)))/len2;
            end
            
            figure(1)
            semilogy(1:1:length(measPAPR1),measPAPR1)
            hold on
            semilogy(1:1:length(measPAPR2),measPAPR2)
            grid on
            xlabel('Отсчеты сигнала'),ylabel('PAPR')
            title('График PAPR как скользящее окно по сигналу')
            legend('С рандомизацией потока','Без рандомизации потока')
            hold off
            
            figure(2)
            semilogy(PAPR,CCDF1)
            hold on
            semilogy(PAPR,CCDF2)
            grid on
            xlabel('PAPR'),ylabel('CCDF')
            title('График CCDF(PAPR)')
            axis([0 30 1e-5 1])
            legend('С рандомизацией потока','Без рандомизации потока')
            
            return
        end

        function obj = PAPR(obj, signal, len, window)
            for i = 1: len+1-window
                temp = signal(i : i-1+window);
                measPAPR(i) = 10*log10(max(abs(temp).^2)/mean(abs(temp).^2));
            end
            
            obj = measPAPR;
        end

    end
end
