{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    waveforms.url = "github:liff/waveforms-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, waveforms, ... }@attrs: {
    hostname = "fjorge-nixos-laptop";
    version = "24.11";

    nixosConfigurations.${self.hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = attrs;

      modules = [
        nixos-hardware.nixosModules.framework-12th-gen-intel

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
        }

        waveforms.nixosModule

        ./configuration.nix
        # Include the results of the hardware scan.
        ./config/hardware-configuration.nix
        # Firefox
        ./config/firefox-configuration.nix
        # power management
        ./config/power-configuration.nix
        # Noise cancellation through PipeWire
        ./config/pw_rnnoise.nix

        ./users/fjorge.nix
      ];
    };
  };
}
