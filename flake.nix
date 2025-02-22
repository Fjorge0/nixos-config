{
  inputs = {
    configs = {
      url = "path:./config";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-quartus.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    ccsstudio.url = "github:Legend-Power-Systems/ccs-nix/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ccsstudio, ... } @ inputs: let inherit (self) outputs; in {
    hostname = "fjorge-nixos-laptop";
    version = "24.11";

    overlays = import ./overlays.nix {inherit inputs;};

    nixosConfigurations.${outputs.hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {inherit inputs outputs;};

      modules = [
        nixos-hardware.nixosModules.framework-12th-gen-intel

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
        }

        { environment.systemPackages = [ ccsstudio.packages.x86_64-linux.default ]; }

        ./configuration.nix

        # Include the results of the hardware scan.
        "${inputs.configs}/nix/hardware-configuration.nix"
        # Firefox
        "${inputs.configs}/nix/firefox-configuration.nix"
        # power management
        "${inputs.configs}/nix/power-configuration.nix"
        # Noise cancellation through PipeWire
        "${inputs.configs}/nix/pw_rnnoise.nix"

        ./users/fjorge.nix
      ];
    };
  };
}
