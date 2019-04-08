close all

[y,fs] = audioread("input.aif");

N = length(y)
freq_axis = (-((N-1)/2):1:(N-1)/2)*fs/N;

figure()
plot(freq_axis, abs(fftshift(fft(y))))
title("before processing")

%Constant Parameters
window_size = 2500;
findpeaks_threshold = 0.2;
numharms = 4;
mask_width = 5;

%Freq note shifts
harmonic_third = 1.25; %Corresponds to a third


num_windows = floor(N / window_size);

final_time = [];


for window = 0:num_windows-1
   %endless loop
   
   %truncate signal to window size
   windowed_signal = y((window*window_size)+1:(window+1)*window_size);% .* hamming(window_size);
   
   %{
   figure()
   plot(windowed_signal)
   title(num2str(window))
   %}
   
   %fft of that window
   freq_signal = (fft(windowed_signal));
   
    half_freq = freq_signal(1:window_size/2);
   
    freq_axis = (1:(window_size)/2)*fs/window_size;
    
    %{
    figure()
    plot(freq_axis, abs(half_freq))
    title("Positive side of FFT of window in Hz" + num2str(window))
   %} 
    
   %find peaks, shift
   [peak_val, peak_loc] = findpeaks(abs(half_freq), 'Threshold', findpeaks_threshold, 'SortStr', 'descend');
   
   num_peaks_considered = min(numharms, size(peak_loc));
   
   
   peaks_considered = peak_loc(1:num_peaks_considered);
   
   mask_window = zeros(window_size/2, 1);
   
   for peak = 1:num_peaks_considered
      mask_window(max(floor(peaks_considered(peak)-(mask_width/2)), 1):min(floor(peaks_considered(peak)+(mask_width/2)),floor(window_size/2))) = 1; 
   end
   
   cleaned_up = half_freq .* mask_window;
   
   %{
   figure();
   plot(freq_axis, abs(cleaned_up))
   title("Peaks and 'regions of influence' of FFT of window " + num2str(window));
   %}
   
   final_signal = zeros(window_size/2, 1);
   for index = 1:(window_size/2)
       scaled_index = floor(index * harmonic_third);
       if (cleaned_up(index) > 0)
          final_signal(scaled_index) = cleaned_up(index);
       end
   end
   
   final_signal = final_signal + half_freq;

   
   %flip it over, ifft
   ultimate_signal = [final_signal; flipud(final_signal)];
   
   %{
   figure();
   plot(abs(flipud(fi
nal_signal)));
   title("final signal (flipped) " + num2str(window))
   
   
   figure();
   plot(abs(final_signal));
   title("Combined FFT of windowed signal with shifted peaks " + num2str(window))
   
   
   figure();
   plot(abs(ultimate_signal));
   title("Combined FFT of windowed signal with peaks " + num2str(window))
   %}

   %ifft
   
   time_domain = ifft(ultimate_signal, 'symmetric');
   
   
   %{
   figure();
   plot(time_domain);
   title("time domain " + num2str(window))
   %}
   
   final_time = [final_time; time_domain];
   
   %append it to output array
end

%olay output array
plot(final_time);
title("Final Time Domain Signal")
xlabel("Time")
%sound(final_time, fs)

audiowrite("final.wav",final_time, fs);

