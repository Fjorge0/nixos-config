{ outputs, pkgs, lib, home-manager, ... }:
{
  users.groups.fjorge = {};

  users.users.fjorge = {
    initialPassword = "password";
    createHome = true;
    isNormalUser = true;

    group = "fjorge";
    extraGroups = [
      "wheel"
      "adm"
      "networkmanager"
      "video"
      "audio"
      "plugdev"
      "log"
    ];

    uid = 1000;
  };

  home-manager.users.fjorge = {
    home.stateVersion = outputs.version;

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

        foreground = "#FEFEFE";
        background = "#0F0F0F";
        selection_foreground = "#FEFEFE";
        selection_background = "#454545";
        # Cursor colors
        cursor = "#E6E0C2";
        cursor_text_color = "#1F1F28";
        # URL underline color when hovering with mouse
        # kitty window border colors
        # OS Window titlebar colors
        # Tab bar colors
        active_tab_foreground = "#FEFEFE";
        active_tab_background = "#614A82";
        inactive_tab_foreground = "#FEFEFE";
        inactive_tab_background = "#363644";
        # Colors for marks (marked text in the terminal)
        # The basic 16 colors
        # black
        color0  = "#1F1F28";
        color8  = "#3C3C51";
        # red
        color1  = "#E46A78";
        color9  = "#EC818C";
        # green
        color2  = "#98BC6D";
        color10 = "#9EC967";
        # yellow
        color3  = "#E5C283";
        color11 = "#F1C982";
        # blue
        color4  = "#7EB3C9";
        color12 = "#7BC2DF";
        # magenta
        color5  = "#957FB8";
        color13 = "#A98FD2";
        # cyan
        color6  = "#7EB3C9";
        color14 = "#7BC2DF";
        # white
        color7  = "#DDD8BB";
        color15 = "#A8A48D";
        # You can set the remaining 240 colors as color16 to color255.
      };
    };
  };
}
