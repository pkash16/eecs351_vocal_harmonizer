close all

[y,fs] = audioread("violins.wav");

y = y(:,1);

t = 0:1/fs:4;
sin_wave = (sin(2*pi*400*t))' * 0.2;% + ((sin(2*pi*400*1.25*t))' * 0.2);

%noise = 0.001 * randn(1,length(sin_wave));

%temp override
%y = sin_wave;


N = length(y)
freq_axis = (-((N-1)/2):1:(N-1)/2)*fs/N;

figure()
plot(freq_axis, abs(fftshift(fft(y))))
title("before processing")

window_size = 6000;

num_windows = floor(N / window_size);

final_time = [y(1:window_size); zeros(length(y)-window_size, 1)];
%FROM NO WINDOWING
%final_time = [];
for window = 1:num_windows-1
   %endless loop
   
   %truncate signal to window size
   windowed_signal = y((window*window_size)+1:(window+1)*window_size) .* hanning(window_size);
   windowed_signal2 = y((window*window_size)+1-(window_size/2):(window+1)*window_size-(window_size/2)) .* hanning(window_size);
   
   

   ultimate1 = peakshift(windowed_signal, window_size, fs);
   ultimate2 = peakshift(windowed_signal2, window_size, fs);   
   
   %ultimate1 = fft(windowed_signal);
   %ultimate2 = fft(windowed_signal2);
   
   %ifft
   %time_domain = real(ifft(ultimate1));%, 'symmetric');
   %time_domain2 = real(ifft(ultimate2));%, 'symmetric');
   
   time_domain = ifft(ultimate1, 'symmetric');
   time_domain2 = ifft(ultimate2, 'symmetric');
   
   
   overlap = [time_domain2; zeros(window_size/2, 1)] + [zeros(window_size/2,1); time_domain];
   
   %{
   figure();
   plot(time_domain);
   title("time domain " + num2str(window))
   %}
   
   beginning_pad = window_size/2 + (window-1)*window_size;
   padded_overlap = [zeros(beginning_pad, 1); overlap; zeros(length(final_time) - beginning_pad - length(overlap), 1)];
   
   final_time = final_time + padded_overlap;
   
   %FROM no windowing
   %final_time = [final_time; time_domain];
   
   %append it to output array
end

%olay output array
final_time = final_time/max(abs(final_time));

plot(final_time);
title("Final Time Domain Signal")
xlabel("Time")

figure();
plot(abs(fftshift(fft(final_time))));
xlabel("Frequency");

sound(final_time, fs)

audiowrite("output_audio/window_correct.wav",final_time, fs);
