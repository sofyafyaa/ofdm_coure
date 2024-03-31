function NoisedSignal = Noise(Signal, SNR)

SNR2Lin = PowerSignal(Signal)/10^(SNR/10);

Noise =   (normrnd(0, sqrt(SNR2Lin/2), size(Signal)) + ...
        1j*normrnd(0, sqrt(SNR2Lin/2), size(Signal)));

NoisedSignal = Signal + Noise;

end

