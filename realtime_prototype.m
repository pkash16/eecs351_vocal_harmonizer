function [output_signal] = realtime_prototype (input_signal, WINDOW_SIZE, SAMPLE_RATE)
    %take hann window of the input signals two channels
    input_signal1 = input_signal(1:WINDOW_SIZE) .* hann(WINDOW_SIZE);
    input_signal2 = input_signal((WINDOW_SIZE/2 + 1):end) .* hann(WINDOW_SIZE);

    %run peakshift on the signals
    ultimate1 = peakshift(input_signal1, WINDOW_SIZE, SAMPLE_RATE);
    ultimate2 = peakshift(input_signal2, WINDOW_SIZE, SAMPLE_RATE);

    %ifft for time domain
    time_domain1 = ifft(ultimate1, 'symmetric');
    time_domain2 = ifft(ultimate2, 'symmetric');

    %append to output signal
    output_signal = [time_domain1; zeros(WINDOW_SIZE/2, 1)] + [zeros(WINDOW_SIZE/2,1); time_domain2];

end