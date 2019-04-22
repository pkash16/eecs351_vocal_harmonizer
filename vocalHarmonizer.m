classdef vocalHarmonizer < audioPlugin
    properties
    end
    properties(Access = private)
        runningFrameSize = [];
    end
    properties (Constant)
        PluginInterface = audioPluginInterface()                     %<---
    end
    methods
        function plugin = vocalHarmonizer
            %no parameters....
        end
        function out = process(plugin,in)
            sum(in, 2);
            frameSize = size(in,1);
            plugin.runningFrameSize = [plugin.runningFrameSize; frameSize];
            if(size(runningFrameSize, 1) < 6000)
                outmono = [zeros(); zeros()];
            else
                ultimate1 = peakshift(sum(in,2), frameSize, 44100);

                outmono = real(ifft(ultimate1));%,'symmetric');
                if(length(outmono) < frameSize)
                    outmono = [outmono(1:end); zeros(frameSize - length(outmono), 1)];
                end
                out = [outmono,outmono];
            end
          end
        function reset(plugin)
            %
        end
    end
end