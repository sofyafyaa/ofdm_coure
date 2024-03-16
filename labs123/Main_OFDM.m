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
T_guard = N_fft/32; % длина защитного интервала

QAM_cells = 10; % количетсво точек созвездия
N_OFDM_Frames = 10; % количество кадров
N_OFDM_Symbols = 5; % количество символов в кадре
QAM_Cells = N_carrier * N_OFDM_Frames * N_OFDM_Symbols; % Кол-во IQ-точек на выходе модулятора
Size_Buffer = IQ2bits(QAM_Cells, constellation);

InitSeq_RAND = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; % Нач. зн. РСЛОС, блок ранд. ВКЛ
InitSeq = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % Нач. зн. РСЛОС, без рандомизации потока

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
% plot(abs(fft(Tx_OFDM_Signal)))
% grid on
% xlabel('frequency'), ylabel('amplitude')
% title('OFDM signal frequency response')
% 
% figure
% plot(abs(fft(Tx_OFDM_Signal(1:1024))))
% grid on
% xlabel('frequency'), ylabel('amplitude')
% title('OFDM symbol frequency response')

%% Channel

% noiseData = Noise (Tx_OFDM_Signal, SNR);
% freq_shifted_data = frequense_shift(noiseData, Freq_shift, N_fft,T_guard);
% multi_data = multipath(freq_shifted_data,channel);

Time_delay = 1;
Tx_OFDM_Signal_delay = delay(Tx_OFDM_Signal, Time_delay);

%% PARP & CCDF

s1 = Tx_OFDM_Signal;
s2 = RAND_Tx_OFDM_Signal;

PAPR = 0:0.01:35;

win = 1024;
PAPR1 = calculate_PAPR(s1, win);
PAPR2 = calculate_PAPR(s2, win);

CCDF1 = zeros(1, length(PAPR));
CCDF2 = zeros(1, length(PAPR));

for i = 1:length(PAPR)
    CCDF1(i) = length(find(PAPR1 >= PAPR(i)))/length(s1);
    CCDF2(i) = length(find(PAPR2 >= PAPR(i)))/length(s2);
end

figure(1)
semilogy(1:1:length(PAPR1), PAPR1, "DisplayName", 'Without Scrambler')
hold on
semilogy(1:1:length(PAPR2), PAPR2, "DisplayName", 'With Scrambler')
grid on
xlabel('Signal'),ylabel('PAPR')
title('PAPR with window method')
legend
hold off
            
figure(2)
semilogy(PAPR, CCDF1, "DisplayName", 'Without Scrambler')
hold on
semilogy(PAPR, CCDF2, "DisplayName", 'With Scrambler')
grid on
xlabel('PAPR'), ylabel('CCDF')
title('CCDF(PAPR)')
axis([0 30 1e-5 1])
legend

%% Receiver

Rx_IQ_points = OFDM_Signal_Demod(Tx_OFDM_Signal_delay, N_fft, T_guard, N_carrier);
RAND_Rx_IQ_points = OFDM_Signal_Demod(RAND_Tx_OFDM_Signal, N_fft, T_guard, N_carrier);

Output_Bit_Buffer = demapping(Rx_IQ_points, constellation, 0, 0);
RAND_Output_Bit_Buffer = demapping(RAND_Rx_IQ_points, constellation, 0, 0);
DERAND_Output_Bit_Buffer = randomizer(RAND_Output_Bit_Buffer, InitSeq_RAND);

Probability = Error_check(Input_Bit_Buffer, Output_Bit_Buffer);
RAND_Probability = Error_check(Input_Bit_Buffer, DERAND_Output_Bit_Buffer);
