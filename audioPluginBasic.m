classdef audioPluginBasic < audioPlugin
    properties
        Frequency = 1;
    end
    properties(Access = private)
        Sine
        Cosine
    end
    properties (Constant)
        PluginInterface = audioPluginInterface(...          %<---
            audioPluginParameter('Frequency',...            %<---
            'DisplayName','Oscillation Frequency',...       %<---
            'Label','Hz',...                                %<---
            'Mapping',{'lin',0.01,10}))                     %<---
    end
    methods
        function plugin = audioPluginBasic
            plugin.Sine = audioOscillator(...
                'DCOffset',1);
            plugin.Cosine = audioOscillator(...
                'DCOffset',1,...
                'PhaseOffset',0.5);
        end
        function out = process(plugin,in)
            frameSize = size(in,1);

            plugin.Sine.Frequency = plugin.Frequency;       %<---
            plugin.Cosine.Frequency = plugin.Frequency;     %<---

            plugin.Sine.SamplesPerFrame = frameSize;
            plugin.Cosine.SamplesPerFrame = frameSize;

            mono = 0.5*sum(in,2);
            gainLeft = step(plugin.Sine);
            gainRight = step(plugin.Cosine);
            out = [mono,mono].*[gainLeft,gainRight];
        end
        function reset(plugin)
            plugin.Sine.SampleRate = getSampleRate(plugin);
            plugin.Cosine.SampleRate = getSampleRate(plugin);
        end
    end
end