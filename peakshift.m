function [ultimate_signal] = peakshift(windowed_signal, window_size, fs) 
   %{
   figure()
   plot(windowed_signal)
   title(num2str(window))
   %}

    %Constant Parameters
    findpeaks_threshold = 0.2;%0.2;
    numharms = 4;
    mask_width = 5;
    
    %Freq note shifts
    harmonic_third = 1.25; %Corresponds to a third
    harmonic_fifth = 1.5;

   
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
   
   shifted_signal1 = zeros(window_size/2, 1);
   for index = 1:num_peaks_considered
      signal_index = peaks_considered(index);
      scaled_index = floor(signal_index*harmonic_fifth);
      
      shifted_signal1(scaled_index-mask_width:scaled_index+mask_width) = cleaned_up(signal_index-mask_width:signal_index+mask_width);
   end
   
   
   shifted_signal2 = zeros(window_size/2, 1);
   for index = 1:num_peaks_considered
      signal_index = peaks_considered(index);
      scaled_index = floor(signal_index*harmonic_third);
      
      shifted_signal2(scaled_index-mask_width:scaled_index+mask_width) = cleaned_up(signal_index-mask_width:signal_index+mask_width);
   end
   
   %{
   final_signal = zeros(window_size/2, 1);
   for index = 1:(window_size/2)
       scaled_index = floor(index * harmonic_fifth);
       if (cleaned_up(index) > 0)
          final_signal(scaled_index) = cleaned_up(index);
       end
   end
   
   %what if we tried shifting it over instead?
   
   
   shifted_signal2 = zeros(window_size/2, 1);
   for index = 1:(window_size/2)
       scaled_index = floor(index * harmonic_third);
       if (cleaned_up(index) > 0)
          shifted_signal2(scaled_index) = cleaned_up(index);
       end
   end
   
   final_signal = final_signal + half_freq + shifted_signal2;
    %}

   final_signal = half_freq + shifted_signal1 + shifted_signal2;
   
   %flip it over, ifft
   ultimate_signal = [final_signal; flipud(final_signal)];
   
   %{
   figure();
   plot(abs(flipud(final_signal)));
   title("final signal (flipped) " + num2str(window))
   
   
   figure();
   plot(abs(final_signal));
   title("Combined FFT of windowed signal with shifted peaks " + num2str(window))
   
   
   figure();
   plot(abs(ultimate_signal));
   title("Combined FFT of windowed signal with peaks " + num2str(window))
   %}