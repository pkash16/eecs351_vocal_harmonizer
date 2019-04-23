function [ultimate_signal] = peakshift(windowed_signal, window_size, fs)

    %Constant Parameters, may need to be tweaked based on other parameters
    %such as window size or instrument input and how many harmonies it has
    findpeaks_threshold = 0.2;%0.2;
    numharms = 6;
    mask_width = 20; %5;
    
    %Freq note shifts: not all are used but we left them for hotswapping
    %harmonies!
    harmonic_third = 1.25; %Corresponds to a third
    harmonic_fifth = 1.5;
    harmonic_second = 9.0/8.0;
    harmonic_seventh = 15.0/8.0;
    minor_third = 6.0/5.0;
    minor_seventh = 16.0/9.0;
   
   %fft of that window
    freq_signal = (fft(windowed_signal));
    %half the frequency signal, used so we don't have to compute the same
    %operation on both halves
    half_freq = freq_signal(1:floor(window_size/2));
 
    %used for plotting axes
    freq_axis = (1:(window_size)/2)*fs/window_size;
    
    %{
    figure()
    plot(freq_axis, abs(half_freq))
    title("Positive side of FFT of window in Hz" + num2str(window))
    %}
    
   
   %find peaks, shift
   peak_loc=[];
   if(length(half_freq) > 3)
       %find the peaks in sorted order 
       [peak_val, peak_loc] = findpeaks(abs(half_freq), 'Threshold', findpeaks_threshold, 'SortStr', 'descend');
   end
   
   %only select how many peaks are available or only the best ones 
   num_peaks_considered = min(numharms, size(peak_loc, 1));
   
   if(num_peaks_considered == 0)
       final_signal = half_freq;
   else
       peaks_considered = peak_loc(1:num_peaks_considered, 1);
       mask_window = zeros(floor(window_size/2), 1);

       for peak = 1:num_peaks_considered
           %take only 
          mask_window(max(floor(peaks_considered(peak)-(mask_width/2)), 1):min(floor(peaks_considered(peak)+(mask_width/2)),floor(window_size/2))) = 1; 
       end
       
       cleaned_up = half_freq .* mask_window;
       shifted_signal1 = shift_signal(cleaned_up, harmonic_third, window_size, peaks_considered, num_peaks_considered, mask_width, fs);
       shifted_signal2 = shift_signal(cleaned_up, harmonic_fifth, window_size, peaks_considered, num_peaks_considered, mask_width, fs);
       %shifted_signal3 = shift_signal(cleaned_up, harmonic_seventh, window_size, peaks_considered, num_peaks_considered, mask_width, fs);
       %shifted_signal4 = shift_signal(cleaned_up, harmonic_second, window_size, peaks_considered, num_peaks_considered, mask_width, fs);
       
       final_signal = half_freq + shifted_signal1 + shifted_signal2;% + shifted_signal3 + shifted_signal4;
   end
   
   %shifted_signal3 = shift_signal(cleaned_up, harmonic_second, window_size, peaks_considered, num_peaks_considered, mask_width, fs);
   %shifted_signal4 = shift_signal(cleaned_up, harmonic_seventh, window_size, peaks_considered, num_peaks_considered, mask_width, fs);
   
   %flip it over, ifft
   ultimate_signal = [final_signal; flipud(final_signal)];