{
  inputs = {
    configs = {
      url = "path:./config";
      flake = false;
    };
    users = {
      url = "path:./users";
      flake = false;
    };
    nixpkgs.url = "https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-quartus.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... } @ inputs: let inherit (self) outputs; in {
    hostname = "fjorge-nixos-laptop";
    version = "25.05";

    overlays = import "${inputs.configs}/nix/overlays.nix" {inherit inputs;};

    nixosConfigurations.${outputs.hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {inherit inputs outputs;};

      modules = [
        nixos-hardware.nixosModules.framework-12th-gen-intel

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
        }

        ./configuration.nix
        # Include the results of the hardware scan.
        ./hardware-configuration.nix

        # Firefox
        "${inputs.configs}/nix/firefox.nix"
        # power management
        "${inputs.configs}/nix/power.nix"
        # Networking
        "${inputs.configs}/nix/networking.nix"

        # Noise cancellation through PipeWire
        "${inputs.configs}/nix/pw-rnnoise.nix"

        # Users
        "${inputs.users}/fjorge.nix"
      ];
    };
  };
}
