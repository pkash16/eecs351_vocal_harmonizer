[y,fs] = audioread("input.aif");

N = length(y)
freq_axis = (-((N-1)/2):1:(N-1)/2)*fs/N;

figure()
plot(freq_axis, abs(fftshift(fft(y))))
title("before processing")

%sound(y, fs)

e = pvoc(y, 0.8);

f = resample(e,4,5); % NB: 0.8 = 4/5
f = pvoc(e, 1.5 * 5/4);
f = resample(f, 3, 2);
soundsc(y(1:length(f))+f,fs)


N_f = length(f)
freq_axis_f = (-((N_f-1)/2):1:(N_f-1)/2)*(fs)/N_f;



figure()
plot(freq_axis_f, abs(fftshift(fft(f))))
title("after processing")

audiowrite("final.wav",y(1:length(f))+f, fs)