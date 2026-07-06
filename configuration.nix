{ inputs, outputs, config, pkgs, ... }:
{
  # NOTE: TEMPORARY FIX nixpkgs@499166
  documentation.doc.enable = false;

  #
  # System Configuration
  #

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs = {
    # Allow UNFREE packages
    config = { allowUnfree = true; allowBroken = false; };

    # Overlay other packages
    overlays = [
      outputs.overlays.unstable
    ];
  };

  # NixOS version
  system.stateVersion = outputs.version;

  # Import other files
  imports = [ ];

  # Boot and Kernel configuration
  boot = {
    consoleLogLevel = 6;
    resumeDevice="/dev/disk/by-uuid/d4ccb1df-9ea1-4876-a39c-cd8892af717d";
    kernelParams = [
      "audit=0"
      "psmouse.synaptics_intertouch=0"
      ''acpi_osi="!Windows 2020"''
      "usbcore.autosuspend=-1"
      #  "resume_offset="
      "sysrq_always_enabled=1"
    ];

    kernel.sysctl = {
      "kernel.sysrq" = 244;
    };

    # Kernel module options
    /*extraModprobeConfig = ''
      options iwlwifi 11n_disable=1 wd_disable=1
    '';*/

    # Bootloader options
    loader = {
      timeout = 1;

      grub.enable = false;
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        editor = false;

        configurationLimit = 4;
      };
    };
  };

  #
  # Packages
  #
  
  # Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Configurable Packages
  programs = {
    xwayland = {
      enable = true;
    };

    nix-ld = {
      enable = true;

      libraries = with pkgs; [
        stdenv.cc
        util-linux
      ];
    };

    dconf.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server

      extest.enable = true; # Better on Wayland
    };

    firefox = {
      enable = true;
      preferences = {
        "browser.tabs.closeWindowWithLastTab" = false;
        "identity.fxaccounts.enabled" = false;
        "browser.tabs.groups.enabled" = true;
      };
      
      # Extensions
      policies = {
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            "installation_mode" = "force_installed";
            "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          "Bitwarden@bitwarden.com" = {
            "installation_mode" = "force_installed";
            "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          };
        };

        SearchEngines = {
          "Default" = "duckduckgo";
        };
      };
    };

    # nvim
    neovim = {
      enable = true;
      defaultEditor = true;

      vimAlias = true;
      viAlias = true;

      configure = {
        customRC = ''
          lua << EOF
          ${builtins.readFile "${inputs.configs}/programs/nvim/init.lua"}
          EOF
        '';

        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            onedark-nvim

            nvim-autopairs
            guess-indent-nvim
            indent-blankline-nvim
            todo-comments-nvim

            nvim-colorizer-lua

            nvim-lspconfig
            lsp_lines-nvim
            coq_nvim
            coq-artifacts
            coq-thirdparty
            coc-pyright
            vim-nix
            clangd_extensions-nvim

#           nvim-treesitter
#           nvim-treesitter-parsers.c
#           nvim-treesitter-parsers.cpp
#           nvim-treesitter-parsers.python
#           nvim-treesitter-parsers.javascript
#           nvim-treesitter-parsers.markdown
#           nvim-treesitter-parsers.yaml
#           nvim-treesitter-parsers.json
#           nvim-treesitter-parsers.make
#           nvim-treesitter-parsers.cpp
#           nvim-treesitter-parsers.css
#           nvim-treesitter-parsers.html
#           nvim-treesitter-parsers.latex
#           nvim-treesitter-parsers.systemverilog
          ];
        };
      };
    };

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions = {
        enable = true;
        strategy = [ "completion" ];
      };
      vteIntegration = true;

      setOptions = [
        "NO_BEEP"
        "NO_HIST_BEEP"
        "NO_LIST_BEEP"
        "interactivecomments"
        "promptsubst"
      ];
      shellInit = builtins.readFile "${inputs.configs}/programs/zsh/shell.sh";
      promptInit = builtins.readFile "${inputs.configs}/programs/zsh/prompt.sh";
    };

    git = {
      enable = true;
    };

    ssh = {
      extraConfig = ''
        # SSH multiplexing
        Host *
          ControlMaster auto
          ControlPersist yes
          ControlPath ~/.ssh/socket-%C
          ServerAliveInterval 60
          ServerAliveCountMax 5
      '';
    };

    virt-manager = {
      enable = true;
    };
  };

  virtualisation = {
    kvmgt = {
      enable = true;
    };

    libvirtd = {
      enable = true;

      onBoot = "ignore";

      qemu = {
        swtpm.enable = true;

        runAsRoot = true;
      };
    };
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      twemoji-color-font
      hanazono
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Serif CJK SC" ];
        sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK SC" ];
        emoji = [ "Twemoji" ];
      };
    };
  };

  # Other Packages
  environment.systemPackages = with pkgs; [
    # System
    nil
    refind
    gcc
    boost
    gdb
    stdenv
    lcov
    clang_20
    llvmPackages_20.clang-tools
    cmake
    gnumake
    coreutils
    pkg-config
    imagemagick

    (python3.withPackages(packages: with packages; [
      requests pandas seaborn sympy numpy pylint matplotlib
      # Nvim COQ dependencies
      pynvim-pp pyyaml std2
    ]))
    pyright

    pmd
    file
    patchelf
    ruby_4_0
    rubyPackages_4_0.ruby-lsp
    libyaml
    tetex
    bundler
    ctags
    texlab
    ffmpeg
    wineWow64Packages.waylandFull
    perf
    valgrind
    ncurses

    # Class
    verible

    # Misc. Development
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gpsd
    libgpiod
    qtcreator
    can-utils

    # Misc
    libimobiledevice
    nodejs
    yt-dlp

    # Graphical themes
    papirus-icon-theme
    vimix-cursors

    # Graphical Applications
    qalculate-qt
    gimp
    kitty
    libreoffice
    hunspell
    hunspellDicts.en_GB-ise

    (pkgs.symlinkJoin {
      name = "discord";
      paths = [ pkgs.discord ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/Discord \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
        wrapProgram $out/bin/discord \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      '';
    })

    wl-clipboard
    wl-clipboard-x11
    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture
    celluloid
    kdePackages.skanpage

    # Misc.
    prismlauncher
    blender
    prusa-slicer
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    powerdevil
    konsole
    kate
    elisa
    discover
  ];

  /*
    sonnet
    threadweaver
    milou
    oxygen-sounds
    qtvirtualkeyboard
    khelpcenter
    elisa
    gwenview
    okular
    oxygen
    konsole
    konqueror
    libqaccessibilityclient
    kxmlgui
    kxmlrpcclient
    kwrited
  */

  #
  # Users
  #

  users = {
    defaultUserShell = pkgs.zsh;
  };

  #
  # Configuration
  #

  environment.localBinInPath = true;

  # Nix garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
  };

  # Hardware
  hardware = {
    # 3D graphics
    graphics = {
      # Enable
      enable = true;
      enable32Bit = true;

      # Drivers
      extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        ocl-icd
        intel-compute-runtime
      ];
    };

    # Allows control of brightness
    acpilight.enable = true;

    # Enable bluetooth
    bluetooth.enable = true;
  };

  # Allow Pipewire to use realtime scheduler
  security.rtkit.enable = true;

  # systemD services
  services = {
    # iPhone USB hotspot
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    # Firmware updater
    fwupd.enable = true;

    # DBus impl
    dbus.implementation = "broker";

    # Pipewire
    pipewire = {
      enable = true;

      # Allow pipewire to replace audio
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Use wireplumber
      wireplumber.enable = true;

      # Open ports for AirPlay
      raopOpenFirewall = true;

      extraConfig.pipewire = {
        # Enable AirPlay
        "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";

              # increase the buffer size if you get dropouts/glitches
              # args = {
              #   "raop.latency.ms" = 500;
              # };
            }
          ];
        };

        # Improve audio quality
        "11-clock-rate" = {
          "context.properties" = {
            "default.clock.rate" = 44100;
          };
        };

        "12-no-upmixing" = {
          "stream.properties" = {
            "channelmix.upmix" = false;
          };
        };
      };
    };

    # Power saver
    upower = {
      enable = true;

      # When the battery is at 5%, hibernate
      percentageAction = 5;
      criticalPowerAction = "Hibernate";
    };

    # Power buttons and laptop lids
    logind.settings.Login = {
      # Laptop lid events
      HandleLidSwitch = "hybrid-sleep";
      HandleLidSwitchExternalPower = "hybrid-sleep";
      HandleLidSwitchDocked = "hybrid-sleep";

      # Power button events
      HandlePowerKey = "hibernate";
      HandlePowerKeyLongPress = "poweroff";
    };

    # Avahi
    avahi = {
      enable = true;
      nssmdns4 = true;

      # Open firewall for WiFi printers
      openFirewall = true;
    };

    # CUPS
    printing = {
      enable = true;
      webInterface = false; # Disable the web interface (use GUI application instead)

      # cups-browsd
      browsing = true;

      # Drivers
      drivers = with pkgs; [
        gutenprint
	      gutenprintBin
	      hplipWithPlugin
	      postscript-lexmark
	      samsung-unified-linux-driver
	      splix
	      brlaser
	      brgenml1lpr
      	brgenml1cupswrapper
	      cnijfilter2
      ];

      # Print to PDF
      cups-pdf.enable = true;
    };
    system-config-printer.enable = true; # GUI application for configuring CUPS

    # Automatic timezone setting daemon
    geoclue2 = {
      enable = true;
    };

    automatic-timezoned.enable = true;

    # Libinput settings
    libinput = {
      enable = true;

      # Touchpad options
      touchpad = {
        tappingButtonMap = "lrm";
        tapping = true;
        sendEventsMode = "disabled-on-external-mouse";
        disableWhileTyping = true;
        clickMethod = "clickfinger";
        accelProfile = "flat";
      };
    };

    # Display manager settings
    displayManager = {
      sddm = {
        enable = true;
        enableHidpi = true;
        wayland.enable = true;

        settings.General.DisplayServer = "wayland";
      };

      defaultSession = "plasma";
    };

    # X11 settings
    xserver = {
      enable = false;

      # Keyboard layout
      xkb = {
        layout = "us,cn";
        variant = ",altgr-pinyin";
        options = "compose:ralt";
      };

      excludePackages = with pkgs; [
        xterm
      ];
    };

    desktopManager = {
      plasma6 = {
        enable = true;
        enableQt5Integration = true;
      };
    };


    # Allows access to the TPM chip
    tcsd.enable = true;
  };

  # Network options
  networking = {
    hostName = outputs.hostname;
  };

  # Enable xdg-desktop-portal-wlr
  xdg.portal.wlr.enable = true;

  # Localisation settings
  i18n = {
    extraLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_AU.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];

    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "C.utf8";
      LC_MONETARY = "en_US.utf8";
      LC_ADDRESS = "en_US.utf8";
      LC_TELEPHONE = "en_US.utf8";
    };

    inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        waylandFrontend = true;

        addons = with pkgs; [
          kdePackages.fcitx5-qt
          fcitx5-pinyin-zhwiki
          kdePackages.fcitx5-chinese-addons
        ];
      };
    };
  };
  console.useXkbConfig = true;

  # Environment variables
  environment.variables = {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    XDG_BIN_HOME    = "$HOME/.local/bin";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}

# vim: tabstop=2 shiftwidth=2 expandtab
