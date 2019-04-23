function [shifted_signal] = shift_signal(cleaned_up, ratio_shift, window_size, peaks_considered, num_peaks_considered, mask_width, fs)
    
    %needs to be complex for C compilation when turning into VST, but holds
    %the "shifted signal"
    shifted_signal = complex(zeros(floor(window_size/2), 1));
    for index = 1:num_peaks_considered
      %for every index in the peaks, scale the index by the ratio shift
      %(see music table for common harmony ratios)
      signal_index = peaks_considered(index);
      scaled_index = floor(signal_index*ratio_shift);

      %we need to take the inner limits of both signals and use that as
      %our "shifting platform"
      signal_left_span = signal_index - max(signal_index - mask_width, 1);
      signal_right_span = min(signal_index + mask_width, floor(window_size/2)) - signal_index;

      scaled_left_span = scaled_index - max(scaled_index - mask_width, 1);
      scaled_right_span = min(scaled_index + mask_width, floor(window_size/2)) - scaled_index;

       %shift the signal by the inner limits
      left_span = min(scaled_left_span, signal_left_span);
      right_span = min(scaled_right_span, signal_right_span);
    
      %this is the complex exponential for phase correction outlined in
      %LaRoche paper
      freq_shift = (scaled_index - signal_index) * 2*pi/window_size;
        
      %return the phase corrected shifted signal
      shifted_signal(scaled_index-left_span:scaled_index+right_span) = cleaned_up(signal_index-left_span:signal_index+right_span) .* exp(1j*(freq_shift)*window_size/2);
    end

end