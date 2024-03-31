clc; % чистка командного окна
close all; % закрыть дополнительные окна 
clear all; % очистить память
rng(1); % фиксирование начального состояния генератора случайных чисел Матлаба

%% Configuration

% File = 'chimpanzee.txt';
File = 'nabokov.txt';

% constellation = "BPSK";
% constellation = "QPSK";
constellation = "16-QAM";

N_fft = 1024; % длина ДПФ / полезная длительность символа
N_carrier = 100; % кол-во поднесущих
T_guard = N_fft/8; % длина защитного интервала

QAM_cells = 10; % количетсво точек созвездия
N_OFDM_Frames = 10; % количество кадров
N_OFDM_Symbols = 5; % количество символов в кадре
QAM_Cells = N_carrier * N_OFDM_Frames * N_OFDM_Symbols; % Кол-во IQ-точек на выходе модулятора
Size_Buffer = IQ2bits(QAM_Cells, constellation);

InitSeq_RAND = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; % Нач. зн. РСЛОС, блок ранд. ВКЛ
%% Transmitter

Input_Bit_Buffer = file_reader(File, Size_Buffer);
RAND_Input_Bit_Buffer = randomizer(Input_Bit_Buffer, InitSeq_RAND);

Tx_IQ_points = mapping(Input_Bit_Buffer, constellation);
RAND_Tx_IQ_points = mapping(RAND_Input_Bit_Buffer, constellation);

OFDM_symbols = OFDM_Mod(Tx_IQ_points, N_fft, N_carrier, N_OFDM_Frames * N_OFDM_Symbols);
RAND_OFDM_symbols = OFDM_Mod(RAND_Tx_IQ_points, N_fft, N_carrier, N_OFDM_Frames * N_OFDM_Symbols);

Tx_OFDM_Signal = signal_generator(OFDM_symbols, T_guard);
RAND_Tx_OFDM_Signal = signal_generator(RAND_OFDM_symbols, T_guard);

% figure
% plot(abs(fft(RX_Signal)))
% grid on
% xlabel('frequency'), ylabel('amplitude')
% title('OFDM signal frequency response')

% figure
% plot(abs(fft(Tx_OFDM_Signal(1:1024))))
% grid on
% xlabel('frequency'), ylabel('amplitude')
% title('OFDM symbol frequency response')
%% Simulation
SNR_min = 20;
SNR_max = 30;
step = 0.5;

% Time_delay = randi([0, T_guard/4]);
Time_delay = 1000;
Freq_shift = 0.1;
channel = [0, 1; 4, 0.6; 10, 0.3];

BER_res = zeros(1, length(SNR_min:step:SNR_max));
MER_res = zeros(1, length(SNR_min:step:SNR_max));

itter_idx = 1;
for itter_SNR = SNR_min:step:SNR_max
    % Channel
%     RX_Signal_N = Noise(RAND_Tx_OFDM_Signal, itter_SNR);
%     RX_Signal_F = freq_shift(RAND_Tx_OFDM_Signal, Freq_shift, N_fft);

%     k = double(linspace(1, length(RAND_Tx_OFDM_Signal), length(RAND_Tx_OFDM_Signal))); 
%     figure
%     plot(k, abs(fft(RAND_Tx_OFDM_Signal)), k, abs(fft(RX_Signal_F)))
%     grid on
%     xlabel('frequency'), ylabel('amplitude')
%     title('АЧХ')
% 
%     figure
%     scatterplot(RX_Signal_F)

    RX_Signal_H = multipath(RAND_Tx_OFDM_Signal, channel);

    k = double(linspace(1, length(RAND_Tx_OFDM_Signal), length(RAND_Tx_OFDM_Signal))); 
    figure
    plot(k, abs(fft(RAND_Tx_OFDM_Signal)), k, abs(fft(RX_Signal_H)))
    grid on
    xlabel('frequency'), ylabel('amplitude')
    title('АЧХ')

    figure
    scatterplot(RX_Signal_H)

%     RX_Signal_T = delay(RAND_Tx_OFDM_Signal, Time_delay);


    RX_Signal = RX_Signal_H;

    % Receiver
    Rx_IQ_points = OFDM_Signal_Demod(RX_Signal, N_fft, T_guard, N_carrier);
    Output_Bit_Buffer = demapping(Rx_IQ_points, constellation, 0, 0);
    Derand_Output_Bit_Buffer = randomizer(Output_Bit_Buffer, InitSeq_RAND);

    BER_res(itter_idx) = Error_check(Input_Bit_Buffer, Derand_Output_Bit_Buffer);
    MER_res(itter_idx) = MER_my_func(Rx_IQ_points, constellation);
    itter_idx = itter_idx + 1;
end

figure(1)
semilogy(SNR_min:step:SNR_max, BER_res)
grid on
xlabel('SNR, dB'), ylabel('BER')
title('BER(SNR) OFDM Channel with AWGN')

figure(2)
plot(SNR_min:step:SNR_max, MER_res)
grid on
xlabel('SNR, dB'), ylabel('MER')
title('MER(SNR) OFDM Channel with AWGN')

%% PARP & CCDF
% s1 = Tx_OFDM_Signal;
% s2 = RAND_Tx_OFDM_Signal;
% PAPR = 0:0.01:35;
% win = 1024;
% PAPR1 = calculate_PAPR(s1, win);
% PAPR2 = calculate_PAPR(s2, win);
% CCDF1 = zeros(1, length(PAPR));
% CCDF2 = zeros(1, length(PAPR));
% for i = 1:length(PAPR)
%     CCDF1(i) = length(find(PAPR1 >= PAPR(i)))/length(s1);
%     CCDF2(i) = length(find(PAPR2 >= PAPR(i)))/length(s2);
% end
% figure(1)
% semilogy(1:1:length(PAPR1), PAPR1, "DisplayName", 'Without Scrambler')
% hold on
% semilogy(1:1:length(PAPR2), PAPR2, "DisplayName", 'With Scrambler')
% grid on
% xlabel('Signal'),ylabel('PAPR')
% title('PAPR with window method')
% legend
% hold off         
% figure(2)
% semilogy(PAPR, CCDF1, "DisplayName", 'Without Scrambler')
% hold on
% semilogy(PAPR, CCDF2, "DisplayName", 'With Scrambler')
% grid on
% xlabel('PAPR'), ylabel('CCDF')
% title('CCDF(PAPR)')
% axis([0 30 1e-5 1])
% legend

%% Receiver
% 
% Rx_IQ_points = OFDM_Signal_Demod(Tx_OFDM_Signal_delay, N_fft, T_guard, N_carrier);
% RAND_Rx_IQ_points = OFDM_Signal_Demod(RAND_Tx_OFDM_Signal, N_fft, T_guard, N_carrier);
% 
% Output_Bit_Buffer = demapping(Rx_IQ_points, constellation, 0, 0);
% RAND_Output_Bit_Buffer = demapping(RAND_Rx_IQ_points, constellation, 0, 0);
% DERAND_Output_Bit_Buffer = randomizer(RAND_Output_Bit_Buffer, InitSeq_RAND);
% 
% Probability = Error_check(Input_Bit_Buffer, Output_Bit_Buffer);
% RAND_Probability = Error_check(Input_Bit_Buffer, DERAND_Output_Bit_Buffer);
