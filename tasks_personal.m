[y, fs] = audioread("input.aif");

window_size = 500; %500 sized window samples
region_size = 50; %50 size regions to "shift"
num_peaks_to_test = 4; %number of peaks to investigate
shifting_phase = 5/4; %shifting phase ratio... major thirds are 5/4.

N = length(y);
freq_axis = (-((N-1)/2):1:(N-1)/2)*fs/N;

figure()
plot(freq_axis, abs(fftshift(fft(y))))
title("before processing")

%we want to take windowed ffts, find peaks, shift, inverse and ad

num_windows = floor(N / window_size); %assuming 0 overlap! Maybe we need to change this
for window_index = 1:num_windows %num_windows
    %take the signal from window index, then multiply it by a hamming
    %window!
    hamming_window = hamming(window_size);
    initial_index = ((window_index-1)*window_size)+1;
    signal_window = y(initial_index:(initial_index+window_size));
    
    final_window = signal_window .* initial_index; %do element by element multiplication
    
    %let's do the fft of the final window!
    response = fft(final_window);
    %find peak, shift, then inverse. place the inverse in the correct
    %sample widnow of the response.
    [peaks, loc_peaks] = findpeaks(abs(response), 'SortStr', 'descend');
    %now we have the location for all the peaks of the response! Let's take
    %a "region" of peaks and use that to copy to higher frequencies
    
    for peak_index = 1:num_peaks_to_test
        current_peak = loc_peaks(peak_index);
        %now that we have the correct peak... take a "range from that peak"
        range_peaks = (current_peak-region_size):current_peak+region_size;
        %freqs_to_shift = response(range_peaks);
        
        %Now that we have some frequencies that we can shift, lets try to
        %shift them!
        current_peak_frequency = fs*current_peak / (window_size+1)
        
        %let's start by getting the exact frequency of the signal....
        %peaks
        
        %response(freqs_to_shift + ) = response(freqs_to_shift);
        
        
    end
    
    
end

sound(y, fs)