# Power usage optimization settings
# https://nixos.wiki/wiki/Laptop

{ config, ... }:

{
  powerManagement = {
    enable = true;

    powertop = {
      enable = true;
    };
  };

  services = {
    thermald.enable = true;

    power-profiles-daemon.enable = false; # This conflicts with TLP

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "superpowersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        PCIE_ASPM_ON_BAT = "powersupersave";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 30;

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
    };
  };

  boot.kernelParams = [
    "nvme.noacpi=1"
    "i915.enable_psr=1"
    "ath9k.ps_enable=1"
  ];
}

# vim: tabstop=2 shiftwidth=2 expandtab
