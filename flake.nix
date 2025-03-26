{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    hugo-papermod = {
      url = "github:adityatelange/hugo-papermod";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      hugo-papermod,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.stdenv.mkDerivation {
            name = "hugo-blog";
            src = self;
            configurePhase = ''
              mkdir -p themes/papermod
              cp -r ${hugo-papermod}/* themes/papermod
            '';
            buildPhase = ''
              ${pkgs.hugo}/bin/hugo --minify
            '';
            installPhase = "cp -r public $out";
          };
        }
      );
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              hugo
            ];
            shellHook = ''
              mkdir -p themes
              ln -sfn ${hugo-papermod} themes/papermod
            '';
          };
        }
      );
    };
}
