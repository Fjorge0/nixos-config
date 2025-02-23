{ pkgs, ... }:

{
  networking = {
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

  services = {
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
}

# vim: tabstop=2 shiftwidth=2 expandtab
