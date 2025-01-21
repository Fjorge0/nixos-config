{ inputs, ... }:
{
  /*
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
  */

  quartus = final: _prev: {
    quartus = import inputs.nixpkgs-quartus {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
