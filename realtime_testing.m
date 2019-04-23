%% Real-Time Audio Stream Processing
%
% The Audio System Toolbox provides real-time, low-latency processing of
% audio signals using the System objects audioDeviceReader and
% audioDeviceWriter.
%
% This example shows how to use our vocal harmonizer functions in real time
% to output harmonies

%constants, the larger the window size, the more the delay
WINDOW_SIZE = 6000;
SAMPLE_RATE = 44100;

%% Create input and output objects
deviceReader = audioDeviceReader;
deviceReader.SampleRate = SAMPLE_RATE;
deviceReader.SamplesPerFrame = WINDOW_SIZE;
deviceWriter = audioDeviceWriter('SampleRate',deviceReader.SampleRate);

disp('Begin Signal Input...')

%simple counter to hold state if we have had previous state or not
counter = 0;

%initialize variables to hold current and previous signal. We need the
%previous signal to do the overlapping windows!
mySignal = zeros(WINDOW_SIZE, 1);
myProcessedSignal = zeros(WINDOW_SIZE + WINDOW_SIZE/2, 1);
prevSignal = zeros(WINDOW_SIZE, 1);
prevProcessedSignal = zeros(WINDOW_SIZE + WINDOW_SIZE/2, 1);

tic
while toc<100
    if counter > 1
        %populate mySignal with the new buffer
        mySignal = deviceReader();
        %call the realtime_prototype function that takes in the signals and
        %outputs the peakshifts
        myProcessedSignal = realtime_prototype([prevSignal(length(prevSignal)/2 + 1:end); mySignal], WINDOW_SIZE, SAMPLE_RATE);
        %take the appropriate output from the end of the previous Signal
        %and the first part of the new signal, and write to the output
        %buffer
        metaOutput = ([prevProcessedSignal(WINDOW_SIZE+1:end); zeros(WINDOW_SIZE, 1)] + myProcessedSignal) * 0.5;
        deviceWriter(metaOutput(1:WINDOW_SIZE));
    end
    prevSignal = mySignal;
    prevProcessedSignal = myProcessedSignal;
    counter = counter + 1;
end
disp('End Signal Input')

release(deviceReader)
release(deviceWriter)