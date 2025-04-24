{
  description = "KDE-platform apps compiled for Darwin";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-24.11-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } ({ self, ... }: {
    flake.overlays.default = import ./overlay.nix;

    systems = inputs.nixpkgs.lib.platforms.darwin;
    perSystem = { pkgs, self', system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };

      packages = {
        dolphin = pkgs.kdePackages.dolphin;
        kcalc = pkgs.kdePackages.kcalc;
        kate = pkgs.kdePackages.kate;
        konsole = pkgs.kdePackages.konsole;
      };

      apps = {
        dolphin = {
          type = "app";
          program = self'.packages.dolphin;
        };
        kcalc = {
          type = "app";
          program = self'.packages.kcalc;
        };
        kate = {
          type = "app";
          program = self'.packages.kate;
        };
        konsole = {
          type = "app";
          program = self'.packages.konsole;
        };
      };
    };
  });
}
