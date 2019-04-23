%Vocal Harmonizer VST plugin
%usage: run validateAudioPlugin and then generateAudioPlugin to create the
%VST
%use the .vst file to plug and play into your favorite DAW!
%there is an issue with the window sizes, so it doesn't work very well but
%if your DAW supports high buffer sizes it will work with big delays

classdef vocalHarmonizer < audioPlugin
    properties
    end
    properties(Access = private)
        runningFrameSize = [];
    end
    properties (Constant)
        PluginInterface = audioPluginInterface()
    end
    methods
        function plugin = vocalHarmonizer
               %put parameters here, in this case maybe MIDI stuff but not
               %implemented yet
        end
        function out = process(plugin,in)
            frameSize = size(in,1);
            ultimate1 = peakshift(sum(in,2), frameSize, 44100);

            outmono = real(ifft(ultimate1));%,'symmetric');
            if(length(outmono) < frameSize)
                outmono = [outmono(1:end); zeros(frameSize - length(outmono), 1)];
            end
            out = [outmono,outmono];
            end
        function reset(plugin)
            %
        end
    end
end