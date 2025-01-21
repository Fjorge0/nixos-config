{ outputs, config, pkgs, ... }:
{
  #
  # System Configuration
  #

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs = {
    # Allow UNFREE packages
    config = { allowUnfree = true; };

    # Overlay other packages
    overlays = [
      #outputs.overlays.unstable-packages
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
    #  "resume_offset="
      "sysrq_always_enabled=1"
    ];

    kernel.sysctl = {
      "kernel.sysrq" = 244;
    };

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
        customRC = ''
          set clipboard+=unnamedplus

          set number
          set relativenumber
          set list
          set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,precedes:«,extends:»

          set tabstop=4
          set shiftwidth=4

          set scrolloff=2

          vnoremap > >gv
          vnoremap < <gv

          nnoremap <leader>d "_d
          xnoremap <leader>d "_d

          nnoremap <CR> :noh<CR><CR>

          let g:onedark_config = {
            \ 'style': 'warmer',
          \}
          colorscheme onedark

          set cursorcolumn
          set cursorline

          augroup cursorline
                au!
                au ColorScheme * hi clear CursorLine
               \ | hi link CursorLine CursorColumn
          augroup END

          let g:vimtex_compiler_method = 'pdflatex'

          au VimLeave * call nvim_cursor_set_shape("vertical-bar")

          let g:coq_settings = {
            \"auto_start": 'shut-up',
            \"display": {
              \"preview": {
                \"border": [
                  \["", "NormalFloat"],
                  \["", "NormalFloat"],
                  \["", "NormalFloat"],
                  \[" ", "NormalFloat"],
                  \["", "NormalFloat"],
                  \["", "NormalFloat"],
                  \["", "NormalFloat"],
                  \[" ", "NormalFloat"] ]}}}

          lua require'colorizer'.setup()

          lua << EOF
            require('guess-indent').setup {}
            require("lsp_lines").setup()

            -- Disable virtual_text since it's redundant due to lsp_lines.
            vim.diagnostic.config({
              virtual_text = false,
            })

            local todoCommentsConfig = require("todo-comments.config")

            require("todo-comments").setup({
              highlight = {
                keyword = "fg",
                after = "",
              },
              keywords = {
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = "󰅒 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "󰆈 ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
                REM  = { icon = "󰅍 ", color = "hint", alt = { "REQUIRES", "EFFECTS", "MODIFIES" } },
              },
            })

            local lsp = require("lspconfig")
            local configs = require("lspconfig.configs")
            local util = require("lspconfig.util")
            local coq = require("coq")

            local remap = vim.api.nvim_set_keymap
            local npairs = require('nvim-autopairs')

            npairs.setup({ map_bs = false, map_cr = false })

            vim.g.coq_settings = { keymap = { recommended = false } }

            -- these mappings are coq recommended mappings unrelated to nvim-autopairs
            remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
            remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
            remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
            remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

            -- skip it, if you use another global object
            _G.MUtils= {}

            MUtils.CR = function()
              if vim.fn.pumvisible() ~= 0 then
                if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
                  return npairs.esc('<c-y>')
                else
                  return npairs.esc('<c-e>') .. npairs.autopairs_cr()
                end
              else
                return npairs.autopairs_cr()
              end
            end
            remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

            MUtils.BS = function()
              if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
                return npairs.esc('<c-e>') .. npairs.autopairs_bs()
              else
                return npairs.autopairs_bs()
              end
            end
            remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })

            lsp.nil_ls.setup(coq.lsp_ensure_capabilities())

            lsp.pyright.setup(coq.lsp_ensure_capabilities({
              settings = {
                python = {
                  linting = {
                    pylintEnabled = true
                  }
                }
              }
            }))

            lsp.clangd.setup(coq.lsp_ensure_capabilities({
              cmd = {
                "clangd",
                "--background-index",
                "--completion-style=detailed",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--all-scopes-completion=true",
                "--function-arg-placeholders",
                "--header-insertion-decorators",
                "--suggest-missing-includes",
                "--fallback-style=llvm",
                "-j=4",
              },
              init_options = {
                  clangdFileStatus = true,
                  completeUnimported = true,
                  usePlaceholders = true,
                  clangdSemanticHighlighting = true,
                  fallbackFlags = { "-Wall", "-Wpedantic" },
              },
            }))

            require("clangd_extensions.inlay_hints").setup_autocmd()
            require("clangd_extensions.inlay_hints").set_inlay_hints()

            if not configs.ruby_lsp then
              local enabled_features = {
                "documentHighlights",
                "documentSymbols",
                "foldingRanges",
                "selectionRanges",
                "semanticHighlighting",
                "formatting",
                "codeActions",
              }

              configs.ruby_lsp = {
                default_config = {
                  cmd = { "bundle", "exec", "ruby-lsp" },
                  filetypes = { "ruby" },
                  root_dir = util.root_pattern("Gemfile", ".git"),
                  init_options = {
                    enabledFeatures = enabled_features,
                  },
                  settings = {},
                },
                commands = {
                  FormatRuby = {
                    function()
                      vim.lsp.buf.format({
                        name = "ruby_lsp",
                        async = true,
                      })
                    end,
                    description = "Format using ruby-lsp",
                  },
                },
              }
            end

            lsp.ruby_lsp.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach, capabilities = capabilities }))

            require'nvim-treesitter.configs'.setup {
              -- A list of parser names, or "all" (the listed parsers MUST always be installed)
              --ensure_installed = { "c", "cpp", "python", "javascript", "markdown", "markdown_inline", "yaml", "json", "html", "make", "css", "html", "latex" },

              -- Install parsers synchronously (only applied to `ensure_installed`)
              sync_install = false,

              -- Automatically install missing parsers when entering buffer
              -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
              auto_install = false,

              highlight = {
                enable = true,

                additional_vim_regex_highlighting = false,
              },
            }
          EOF
        '';
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
      shellInit = ''
        # Do menu-driven completion.
        zstyle ':completion:*' menu select

        # Color completion for some things.
        # http://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html

        # formatting and messages
        # http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
        zstyle ':completion:*' verbose yes
        zstyle ':completion:*:descriptions' format "%F{yellow}%B--- %d%b%f"
        zstyle ':completion:*:messages' format '%d'
        zstyle ':completion:*:warnings' format "%F{red}No matches for:%f %d"
        zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
        zstyle ':completion:*' group-name '''
        zstyle ':completion::complete:make::' tag-order 'targets' -
      '';
      promptInit = ''
        # Git ahead and behind
        # https://stackoverflow.com/a/77327346
        function +vi-git-st() {
          local ahead behind
          local -a gitstatus

          git rev-parse @{upstream} >/dev/null 2>&1 || return 0
          local -a x=( $(git rev-list --left-right --count HEAD...@{upstream} ) )
          
          (( $x[1] )) && gitstatus+=( "%F{green}+''${x[1]}%f" )  # ahead count
          (( $x[2] )) && gitstatus+=( "%F{red}-''${x[2]}%f" )  # behind count

          hook_com[branch]+=''${(j:/:)gitstatus}
        }

        # Git tracked and untracked changes
        function +vi-git-changes() {
          local ahead behind
          local -a stagedCount
          local -a unstagedCount
          local -a untrackedCount

          unstagedCount=$(git ls-files -m --exclude-standard | wc -l)
          untrackedCount=$(git ls-files -o --exclude-standard | wc -l)
          stagedCount=$(git diff --cached --numstat | wc -l) # https://stackoverflow.com/a/3162492

          hook_com[misc]="%F{green}''${stagedCount}S%F{yellow} ''${unstagedCount}M%F{red} ''${untrackedCount}U%f"
        }

        # VCS info
        autoload -Uz vcs_info
        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:git*' check-for-changes false
        zstyle ':vcs_info:git*' get-revision true
        zstyle ':vcs_info:git*+set-message:*' hooks git-st git-changes
        zstyle ':vcs_info:git*' formats '%f(%s)-[%F{magenta}%b%f %F{yellow}#%7.7i%f]-[%m]'
        zstyle ':vcs_info:git*' actionformats '%f(%s)-[%F{magenta}%b%f %F{yellow}#%7.7i%f]-[%m]-(%F{blue}%a%f)'
        precmd () { vcs_info }

        PROMPT=$'[%F{red}%D{%T %Z %e/%m/%Y}%f] [%F{cyan}%y%f] ''\${vcs_info_msg_0_}\n%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '
        RPROMPT='[%F{yellow}%?%f]'

        TIMEFMT=$'%J\ntotal\t%*E\nuser\t%*U\nsys\t%*S\n\nCPU\t%P\nMemory\t%MkB\nI/O\t%I/%O'
      '';
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
    (python312.withPackages(python312Packages: with python312Packages; [compiledb requests numpy pylint]))
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
    discord-canary

    #(pkgs.symlinkJoin {
    #  name = "discord-canary";
    #  paths = [ pkgs.discord-canary ];
    #  buildInputs = [ pkgs.makeWrapper ];
    #  postBuild = ''
    #    wrapProgram $out/bin/DiscordCanary \
    #      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    #    wrapProgram $out/bin/discordcanary \
    #      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    #  '';
    #})
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
      wifi.powersave = true;
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
