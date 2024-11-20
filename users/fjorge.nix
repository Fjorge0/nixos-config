{ self, pkgs, lib, home-manager, ... }:
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager.users.fjorge = {
    home.stateVersion = self.version;

    programs.kitty = lib.mkForce {
      enable = true;

      settings = {
        confirm_os_window_close = 0;

        cursor_shape = "beam";
        cursor_shape_unfocused = "underline";

        show_hyperlink_targets = true;
        underline_hyperlinks = "always";

        enable_audio_bell = false;
        visual_bell_duration = 1.0;
        window_alert_on_bell = true;

        mouse_hide_wait = "0";
        window_padding_width = 10;
      };
    };
  };
}
