classdef SignalGen < handle
    
    % Пропертис! Чтобы удобнее можно было наблюдать, что творится при
    % работе с классом
    properties
        N_fft; % длина ДПФ
        T_u; % полезная длительность символа
        N_carrier; % кол-во поднесущих
        OFDM_FrameSize; % кол-во OFDM-символов в кадре
        T_guard; % длина защитного интервала
    end

    % Магические заклинания
    methods        
        % Функция - инициализатор класса. Задает параметры OFDM сигнала.
        function obj = SignalGen(N_fft, N_carrier, OFDM_FrameSize, T_guard)
             if(nargin > 0)
                obj.N_fft = N_fft;
                obj.T_u = obj.N_fft;
                obj.N_carrier = N_carrier;
                obj.OFDM_FrameSize = OFDM_FrameSize;
                obj.T_guard = T_guard;
             end
        end

        function obj = OFDM_Spectrum(obj, data, mode)
            switch mode
                case 'form'
                    spectrum = [zeros(1, 1), data, zeros(1, obj.N_fft-obj.N_carrier-1)];
                    obj = spectrum;
                case 'unform'
                    spectrum = data(:, 2:obj.N_carrier+1);
                    iqdata = reshape(spectrum.', 1, []);
                    obj = iqdata;
            end
            
        end        

        function obj = OFDM_IFFT(obj, spectrum)
            signal = ifft(spectrum, obj.N_fft);
            obj = signal;
        end

        function obj = OFDM_FFT(obj, signal)
            spectrum = fft(signal, obj.N_fft);
            spectrum(abs(spectrum)<(1e-13)) = 0;
            obj = spectrum;
        end

        function obj = OFDM_TGuard(obj, signal, mode)
            switch mode
                case 'insert'
                    for k = 1:obj.OFDM_FrameSize
                        ofdmsignal = [signal(:, end-obj.T_guard+1:end), signal];
                    end
                case 'extract'
                    ofdmsignal = signal(:,obj.T_guard+1:end);
            end
            obj = ofdmsignal;
        end

        function obj = OFDM_Stitching(obj, signal, mode)
            switch mode
                case 'stitch'
                    ofdmsignal = reshape(signal.', 1, []);
                case 'unstitch'
                    ofdmsignal = reshape(signal, obj.N_fft+obj.T_guard, []).';
            end
            obj = ofdmsignal;
        end

    end
end
