function [NoisedSignal, Noise] = NoiseGenerator(Signal, SNR)

P_signal = PowerSignal(Signal);
P_noise = P_signal / 10^(SNR/10);

Noise_real = normrnd(0, sqrt(P_noise/2), [1, length(Signal)]);
Noise_imag = normrnd(0, sqrt(P_noise/2), [1, length(Signal)]);
Noise(1:length(Signal)) = Noise_real(1:length(Signal)) + 1i .* Noise_imag(1:length(Signal));

NoisedSignal(1:length(Signal)) = Signal(1:length(Signal)) + Noise(1:length(Signal));

end