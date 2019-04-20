function [output_signal] = realtime_prototype (input_signal)

ultimate1 = peakshift(input_signal, 8000, 44100);

output_signal = ifft(ultimate1, 'symmetric');
end