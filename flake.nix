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
        kate = pkgs.kdePackages.kate;
        kcalc = pkgs.kdePackages.kcalc;
        kcolorchooser = pkgs.kdePackages.kcolorchooser;
        konsole = pkgs.kdePackages.konsole;
        okular = pkgs.kdePackages.okular;
      };

      apps = builtins.mapAttrs (name: pkg: {
        type = "app";
        program = pkg;
      }) self'.packages;
    };
  });
}
