{ pkgs, config, ... }:
{
  config.services.pipewire = {
    extraLadspaPackages = with pkgs; [ deepfilternet ];

    extraConfig.pipewire."99-noise-suppression" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "DeepFilter Noise Canceling source";
            "media.name" = "DeepFilter Noise Canceling source";

            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "DeepFilter Stereo";
                  plugin = "libdeep_filter_ladspa";
                  label = "deep_filter_stereo";
                  control = {
                    "Attenuation Limit (dB)" = 100;
                  };
                }
              ];
            };

            "audio.rate" = 48000;
            "audio.channels" = 2;
            "audio.position" = [ "FL" "FR" ];

            "capture.props"."node.passive" = true;
            "playback.props"."media.class" = "Audio/Source";
          };
        }
      ];
    };
  };
}
