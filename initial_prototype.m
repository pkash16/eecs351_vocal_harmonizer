close all

FILENAME = "input_files/woods.mp3";

[y,fs] = audioread(FILENAME);

%for removing stereo inputs, we only consider one channel for now!
y = y(:,1);

t = 0:1/fs:4;
N = length(y);
freq_axis = (-((N-1)/2):1:(N-1)/2)*fs/N;

%window size, the smaller the better it is in realtime
window_size = 8000;
num_windows = floor(N / window_size);

%final output array of audio in the time domain
final_time = [y(1:window_size); zeros(length(y)-window_size, 1)];

%FROM NO WINDOWING
%final_time = [];

%loop through the samples
for curr_winow = 1:num_windows-1

   %overlapping windows with hann windowing to sum up to ~1 constant signal
   windowed_signal = y((curr_winow*window_size)+1:(curr_winow+1)*window_size) .* triang(window_size);
   windowed_signal2 = y((curr_winow*window_size)+1-(window_size/2):(curr_winow+1)*window_size-(window_size/2)) .* triang(window_size);

   %run the peakshift algorithm on the window of the time domain, this outputs the new shifted frequencies
   ultimate1 = peakshift(windowed_signal, window_size, fs);
   ultimate2 = peakshift(windowed_signal2, window_size, fs);

   %ifft to go back into time domain
   time_domain = ifft(ultimate1, 'symmetric');
   time_domain2 = ifft(ultimate2, 'symmetric');

   %concatenate the two time domain signals
   overlap = [time_domain2; zeros(window_size/2, 1)] + [zeros(window_size/2,1); time_domain];

   %{
   figure();
   plot(time_domain);
   title("time domain " + num2str(window))
   %}

   %add up the signals in the time domain to the final array
   beginning_pad = window_size/2 + (curr_winow-1)*window_size;
   padded_overlap = [zeros(beginning_pad, 1); overlap; zeros(length(final_time) - beginning_pad - length(overlap), 1)];

   final_time = final_time + padded_overlap;

   %FROM no windowing
   %final_time = [final_time; time_domain];

   %append it to output array
end

%olay output array
final_time = final_time/max(abs(final_time));

%plot the final signal
plot(final_time);
title("Final Time Domain Signal")
xlabel("Time")

%plot the final ffft of the signal
figure();
plot(abs(fftshift(fft(final_time))));
xlabel("Frequency");
title("Final frequency domain signal");

sound(final_time, fs)

%write the output to a file!
audiowrite("output_audio/woods.wav",final_time, fs);
