{
  description = "Core flake exposing tools and utilities provided by SnapSettle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dashnix.url = "github:snapsettle/dashnix";
    nix-helpers.url = "github:snapsettle/nix-helpers";
    gitgetter.url = "github:snapsettle/gitgetter";

    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      dashnix,
      nix-helpers,
      gitgetter,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));

      treefmtConfig = eachSystem (
        pkgs:
        treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true; # Enables the standard nixfmt-rfc-style formatter
        }
      );
    in
    {
      formatter = eachSystem (
        pkgs: treefmtConfig.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
      );

      nixosModules = {
        dashnix = dashnix.nixosModules.default;
        nix-helpers = nix-helpers.nixosModules.default;
        gitgetter = gitgetter.nixosModules.default;

        default = {
          imports = [
            dashnix.nixosModules.default
            nix-helpers.nixosModules.default
            gitgetter.nixosModules.default
          ];
        };
      };

      packages = nixpkgs.lib.genAttrs systems (system: {
        dashnix = dashnix.packages.${system}.default;
        nix-helpers = nix-helpers.packages.${system}.default;
        gitgetter = gitgetter.packages.${system}.default;
      });
    };
}
