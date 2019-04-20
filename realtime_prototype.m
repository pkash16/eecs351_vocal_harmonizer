function [output_signal] = realtime_prototype (input_signal, WINDOW_SIZE, SAMPLE_RATE)

length(input_signal)

input_signal1 = input_signal(1:WINDOW_SIZE) .* hann(WINDOW_SIZE);
input_signal2 = input_signal((WINDOW_SIZE/2 + 1):end) .* hann(WINDOW_SIZE);

ultimate1 = peakshift(input_signal1, WINDOW_SIZE, SAMPLE_RATE);
ultimate2 = peakshift(input_signal2, WINDOW_SIZE, SAMPLE_RATE);

time_domain1 = ifft(ultimate1, 'symmetric');
time_domain2 = ifft(ultimate2, 'symmetric');

output_signal = [time_domain1; zeros(WINDOW_SIZE/2, 1)] + [zeros(WINDOW_SIZE/2,1); time_domain2];

end