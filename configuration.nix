{ inputs, outputs, config, pkgs, ... }:
{
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
      outputs.overlays.quartus
    ];
  };

  # NixOS version
  system.stateVersion = outputs.version;

  # Import other files
  imports = [
  ];

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
            "install_url" = "https://addons.mozilla.org/firefox/downloads/file/4246600/";
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
        customRC = builtins.readFile "${inputs.configs}/programs/nvim/init.vim";

        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            onedark-nvim
            nvim-lspconfig
            vim-nix
            nvim-autopairs
            clangd_extensions-nvim
            coq_nvim
            coq-artifacts
            coq-thirdparty
            coc-pyright
            nvim-colorizer-lua
            guess-indent-nvim
            lsp_lines-nvim
            todo-comments-nvim

            nvim-treesitter
            nvim-treesitter-parsers.c
            nvim-treesitter-parsers.cpp
            nvim-treesitter-parsers.python
            nvim-treesitter-parsers.javascript
            nvim-treesitter-parsers.markdown
            nvim-treesitter-parsers.yaml
            nvim-treesitter-parsers.json
            nvim-treesitter-parsers.make
            nvim-treesitter-parsers.cpp
            nvim-treesitter-parsers.css
            nvim-treesitter-parsers.html
            nvim-treesitter-parsers.latex
            nvim-treesitter-parsers.verilog
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
        ovmf.enable = true;

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
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
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
    stdenv
    lcov
    clang_17
    clang-tools_17
    cmake
    gnumake
    coreutils
    pkg-config
    imagemagick
    (python312.withPackages(packages: with packages; [requests pandas seaborn sympy numpy pylint matplotlib]))
    pyright
    pmd
    file
    patchelf
    ruby_3_2
    rubyPackages_3_2.ruby-lsp
    libyaml
    tetex
    bundler
    ctags
    texlab
    ffmpeg
    wineWowPackages.waylandFull
    linuxPackages_latest.perf
    valgrind
    ncurses

    # Class
    quartus.quartus-prime-lite

    # Spork
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gpsd
    libgpiod
    qt6Packages.full
    qtcreator
    can-utils

    # Misc
    libimobiledevice
    nodejs
    yt-dlp

    # Graphical themes
    papirus-icon-theme
    vimix-cursor-theme

    # Graphical Applications
    qalculate-gtk
    librewolf
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

    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-python.python
        ms-vsliveshare.vsliveshare
        ms-vscode.cpptools
        ms-pyright.pyright
        llvm-vs-code-extensions.vscode-clangd
        vadimcn.vscode-lldb
      ];
    })
    wl-clipboard
    wl-clipboard-x11
    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture
    celluloid
    libsForQt5.skanpage
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    powerdevil
    konsole
    kate
    elisa
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
    users = {
      fjorge = {
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
    };

    groups = {
      fjorge = {};
    };

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

      # Improve audio quality?
      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.rate" = 44100;
          };
        };

        "11-no-upmixing" = {
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
    logind = {
      # Laptop lid events
      lidSwitch = "hybrid-sleep";
      lidSwitchExternalPower = "hybrid-sleep";
      lidSwitchDocked = "hybrid-sleep";

      # Power button events
      extraConfig = "HandlePowerKey=hybrid-sleep
                     HandlePowerKeyLongPress=poweroff";
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
      appConfig = {
        "localtimed" = {
          isAllowed = true;
          isSystem = true;
        };
      };
    };

    localtimed.enable = true;

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

    # DNS encryption
    dnscrypt-proxy2 = {
      enable = true;

      settings = {
        # Use IPv6 DNS servers
        ipv6_servers = true;

        # Require DNSsec
        require_dnssec = true;

        # Enable Oblivious DOH
        odoh_servers = true;

        # Requirements
        require_nofilter = true;
        require_nolog = true;

        # Enable experimental http3 support
        http3 = true;

        # Disable cache
        cache = false;

        # Configure sources
        sources = {
          public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
            ];
            cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };

          replays = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
              "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
            ];
            cache_file = "/var/lib/dnscrypt-proxy2/relays.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };

          odoh-servers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
            ];
            cache_file = "/var/lib/dnscrypt-proxy2/odoh-servers.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };

          odoh-relays = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
              "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
            ];
            cache_file = "/var/lib/dnscrypt-proxy2/odoh-relays.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };
        };

        # Disable Google's DNS servers
        disabled_server_names = [ "google" ];

        # Set port to 53000
        listen_addresses = ["127.0.0.1:53000" "[::1]:53000"];
      };
    };

    unbound = {
      enable = true;

      settings = {
        server = {
          do-not-query-localhost = "no";

          # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;

          # Custom settings
          hide-identity = true;
          hide-version = true;
        };

        forward-zone = {
          name = ".";
          forward-addr = ["::1@53000" "127.0.0.1@53000"];
        };
      };
    };
  };

  # Network options
  networking = {
    hostName = outputs.hostname;

    networkmanager = {
      # Enable NetworkManager
      enable = true;

      dns = "none";
      wifi = {
        powersave = false;
        #backend = "iwd";
      };
    };

    wireless = {
      iwd = {
        # Enable iwd
        enable = false;

        settings = {
          IPv6 = {
            Enabled = true;
          };
        };
      };
    };

    useDHCP = false;
    dhcpcd = {
      enable = false;
      extraConfig = "nohook resolv.conf";
    };

    # Manually setting nameservers (for dnscrypt)
    nameservers = [ "127.0.0.1" "::1" ];
  };

  # Enable xdg-desktop-portal-wlr
  xdg.portal.wlr.enable = true;

  # Localisation settings
  i18n = {
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_AU.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];

    defaultLocale = "en_GB.utf8";
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
        plasma6Support = true;

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
}

# vim: tabstop=2 shiftwidth=2 expandtab
