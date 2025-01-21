{ config, pkgs, lib, ... }:

let
  json = pkgs.formats.json {};
  pw_rnnoise_config = {
    "context.modules"= [
      { "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Suppressed Source";
          "media.name"       = "Noise Suppressed Source";
          "filter.graph" = {
            "nodes" = [
              {
                "type"   = "ladspa";
                "name"   = "rnnoise";
                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                "label"  = "noise_suppressor_mono";
                "control" = {
                  "VAD Threshold (%)" = 90.0;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 0;
                };
              }
            ];
          };
          "audio.position" = [ "FL" "FR" ];
          "capture.props" = {
            "node.name" = "capture.rnnoise_source";
            "audio.rate" = 48000;
            "media.class" = "Stream/Input/Audio";
            "filter.smart" = true;
            "filter.smart.name" = "rnnoise";
          };
          "playback.props" = {
            "audio.position" = [ "FL" "FR" ];
            "media.class" = "Audio/Source";
            "node.name" = "rnnoise_source";
            #"node.description" = "Noise Suppressed Source";
            "audio.rate" = 48000;
          };
        };
      }
    ];
  };
in
  {
    config.services.pipewire = {
      extraConfig.pipewire."99-noise-suppression" = pw_rnnoise_config;
      /*configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/60-echo-cancel.conf" ''
          context.modules = [
            # Echo cancellation
            {
              name = libpipewire-module-echo-cancel
              args = {
                # Monitor mode: Instead of creating a virtual sink into which all
                # applications must play, in PipeWire the echo cancellation module can read
                # the audio that should be cancelled directly from the current fallback
                # audio output
                monitor.mode = true
                # The audio source / microphone wherein the echo should be cancelled is not
                # specified explicitly; the module follows the fallback audio source setting
                capture.props = {
                  media.class = Stream/Input/Audio
                  filter.smart = true
                  filter.smart.name = echo
                  filter.smart.after = [ rnnoise ]
                }
                source.props = {
                  node.description = "Echo Cancelled Noise Suppressed Source"
                  media.class = Audio/Source
                  audio.position = [ FL FR ]
                  node.passive = true
                  node.dont-remix = true
                }
                aec.args = {
                  # Settings for the WebRTC echo cancellation engine
                  webrtc.gain_control = true
                  webrtc.extended_filter = true
                  webrtc.voice_detection = true
                  # Other WebRTC echo cancellation settings which may or may not exist
                  # Documentation for the WebRTC echo cancellation library is difficult
                  # to find
                  #webrtc.analog_gain_control = false
                  #webrtc.digital_gain_control = true
                  #webrtc.experimental_agc = true
                  webrtc.experimental_ns = true
                  webrtc.noise_suppression = true
                }
              }
            }
          ]
        '')
      ];*/
    };
  }

