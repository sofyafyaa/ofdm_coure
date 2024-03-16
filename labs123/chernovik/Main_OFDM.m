
clc; % Чистка командного окна
close all; % Закрыть дополнительные окна 
clear all; % Очистить память
rng(1); % Зафиксировать начальное состояние генератора случайных чисел Матлаба

%% Конфигурация модели

% Выбор созвездия: BPSK, QPSK, 16-QAM (закомментить)
% Constellation = "BPSK";
% Constellation = "QPSK";
Constellation = "16-QAM";

% Выбор файла для передачи (закомментить)
File = 'Fowles.txt'; % "Коллекционер" Джона Фаулза

N_fft = 1024; % длина ДПФ / полезная длительность символа
N_carrier = 100; % кол-во поднесущих
T_guard = N_fft/8; % длина защитного интервала

OFDM_FrameSize = 5; % кол-во OFDM-символов в кадре
OFDM_NoFrames = 10; % кол-во OFDM кадров

OFDM_NoSymbols = OFDM_FrameSize*OFDM_NoFrames; % кол-во OFDM-символов (всего)

QAM_Cells = N_carrier*OFDM_NoSymbols; % Кол-во IQ-точек на выходе модулятора

InitSeq_RAND = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; % Нач. зн. РСЛОС, блок ранд. ВКЛ
InitSeq = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % Нач. зн. РСЛОС, без рандомизации потока

%% Блок с инициализацией классов

% Класс Modulator -- реализация функций к заданию 1:
% На вход подается конфигурация модели: имя файла и название созвездия
% Кол-во символов созвездия и кол-во битов на символ задаются исходя из
% названия созвездия по инициализации класса и лежат в его пропертис 
M = Modulator(File, Constellation, QAM_Cells);

% Класс SignalGen -- реализация функций к заданию 2:
% На вход подается конфигурация модели: длина ДПФ, кол-во поднесущих,
% кол-во OFDM-символов в кадре, длина защитного интервала
SG = SignalGen(N_fft, N_carrier, OFDM_FrameSize, T_guard);

% Класс Scrambler -- реализация функций к заданию 3:
% Блоки рандомизатора | дерандомизатора, анализ пик-фактора по PAPR | CCDF
RD = Scrambler();

%% Передатчик
%% Функция - созидатель битового потока данных

% Вызываем метод file_reader из класса Modulator
Size_Buffer = QAM_Cells*M.Bit_Depth;
Input_Bit_Buffer = M.file_reader(Size_Buffer);

% Вызываем метод randomizer из класса Scrambler
Input_Bit_Buffer = RD.randomizer(Input_Bit_Buffer, InitSeq);
Input_Bit_Buffer_RAND = RD.randomizer(Input_Bit_Buffer, InitSeq_RAND);

%% Функция - маппер IQ-компонент

% Вызываем метод mapping из класса Modulator и передаем ему вывод 
% метода file_reader - получаем I и Q компоненты
Tx_IQ_points_RAND = M.mapping(Input_Bit_Buffer_RAND);
Tx_IQ_points = M.mapping(Input_Bit_Buffer);

% % %график
% figure(1)
% scatter(real(Tx_IQ_points), imag(Tx_IQ_points))
% scatterplot(Tx_IQ_points)

%% Нормализатор мощности созвездия

% Считаем коэффициент нормировки созвездия, считая, что отправка 
% той или иной iq компоненты равновероятна
Norm_Constellation = M.norm_constellation(M.Base_Constellation_Points);

% Отнормировали IQ компоненты
Tx_IQ_points_RAND = Tx_IQ_points_RAND/Norm_Constellation; 
Tx_IQ_points = Tx_IQ_points/Norm_Constellation; 

%% Формирование спектра и обратное ДПФ для IQ-компонент сигнала... (ПРД)

for i = 1:OFDM_NoSymbols
    % Сформировали полосу
    Tx_OFDM_Spectrum_RAND(i,:) = SG.OFDM_Spectrum(Tx_IQ_points_RAND((i-1)*(N_carrier)+1:i*(N_carrier)), 'form');
    Tx_OFDM_Spectrum(i,:) = SG.OFDM_Spectrum(Tx_IQ_points((i-1)*(N_carrier)+1:i*(N_carrier)), 'form');

    % Взяли обратное Фурье-преобразование
    Tx_OFDM_Symbols_RAND(i,:) = SG.OFDM_IFFT(Tx_OFDM_Spectrum_RAND(i,:));
    Tx_OFDM_Symbols(i,:) = SG.OFDM_IFFT(Tx_OFDM_Spectrum(i,:));

    % Вставили защитный интервал длит. T_guard
    Tx_OFDM_Symbols_TG_RAND(i,:) = SG.OFDM_TGuard(Tx_OFDM_Symbols_RAND(i,:),'insert');
    Tx_OFDM_Symbols_TG(i,:) = SG.OFDM_TGuard(Tx_OFDM_Symbols(i,:),'insert');

    % Сшили символы в один поток, получили OFDM сигнал
    Tx_OFDM_Signal = SG.OFDM_Stitching(Tx_OFDM_Symbols_TG,'stitch');
    Tx_OFDM_Signal_RAND = SG.OFDM_Stitching(Tx_OFDM_Symbols_TG_RAND,'stitch');
end



%% Канал передачи
%%
% канал Lab 4-5 
% noiseData = Noise (Tx_OFDM_Signal, SNR); %lab 4 | добавление абгш
% freq_shifted_data = frequense_shift(noiseData, Freq_shift, N_fft,T_guard); % lab 4 | частотный сдвиг
% multi_data = multipath(freq_shifted_data,channel); % lab 4 | многолучевой прием
% time_shifted_data = delay(multi_data,Time_delay); % lab 4

%% Расшивка, удаление T_Guard, прямое ДПФ... (ПРМ)

% Полученный OFDM сигнал == отправленный OFDM сигнал
Rx_OFDM_Signal_RAND = Tx_OFDM_Signal_RAND;
Rx_OFDM_Signal = Tx_OFDM_Signal;

% Строим графики PAPR, CCDF(PAPR)
RD.CCDF(Rx_OFDM_Signal_RAND,Rx_OFDM_Signal, 1024);

for i = 1:OFDM_NoSymbols
    % Разделили сигнал на отдельные символы
    Rx_OFDM_Symbols_TG_RAND = SG.OFDM_Stitching(Rx_OFDM_Signal_RAND,'unstitch');
    Rx_OFDM_Symbols_TG = SG.OFDM_Stitching(Rx_OFDM_Signal,'unstitch');

    % Удалили защитный интервал
    Rx_OFDM_Symbols_RAND(i,:) = SG.OFDM_TGuard(Rx_OFDM_Symbols_TG_RAND(i,:),'extract');
    Rx_OFDM_Symbols(i,:) = SG.OFDM_TGuard(Rx_OFDM_Symbols_TG(i,:),'extract');

    % Взяли Фурье-преобразование
    Rx_OFDM_Spectrum_RAND(i,:) = SG.OFDM_FFT(Rx_OFDM_Symbols_RAND(i,:));
    Rx_OFDM_Spectrum(i,:) = SG.OFDM_FFT(Rx_OFDM_Symbols(i,:));

    % Получили поток IQ-компонент для отправки на демаппер
    Rx_IQ_points_RAND = SG.OFDM_Spectrum(Rx_OFDM_Spectrum_RAND, 'unform');
    Rx_IQ_points = SG.OFDM_Spectrum(Rx_OFDM_Spectrum, 'unform');
end

%% Денормировка принятого потока IQ-компонент

% Приняли, денормировали перед демаппинг-фицированием..
Rx_IQ_points_RAND = Rx_IQ_points_RAND*Norm_Constellation;
Rx_IQ_points = Rx_IQ_points*Norm_Constellation;

%% Функция - демаппер IQ-компонент

% Очень похожа на маппер, все те же финты и костыли
Output_Bit_Buffer_RAND = M.demapping(Rx_IQ_points_RAND);
Output_Bit_Buffer = M.demapping(Rx_IQ_points);

% Вызываем метод derandomizer из класса Scrambler
Output_Bit_Buffer_RAND = RD.derandomizer(Output_Bit_Buffer_RAND, InitSeq_RAND);
Output_Bit_Buffer = RD.derandomizer(Output_Bit_Buffer, InitSeq);

%%
% Проверяем xor-ом на наличие ошибок передачи потока
Probability_RAND = M.error_check(Input_Bit_Buffer, Output_Bit_Buffer_RAND);
Probability = M.error_check(Input_Bit_Buffer, Output_Bit_Buffer);

%% Big Success!!1
