{
  description = "A flake for installing norpie's st build";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              st-norpie = prev.st.overrideAttrs (oldAttrs: rec {
                version = "master";
                src = ./.;
                buildInputs =
                  oldAttrs.buildInputs
                  ++ [
                    pkgs.imlib2
                  ];
              });
            })
          ];
        };

        libraries = with pkgs; [
          xorg.libX11
          xorg.libXft
          pkg-config
          imlib2
        ];
      in rec {
        apps = {
          st = {
            type = "app";
            program = "${defaultPackage}/bin/st";
          };
        };

        packages.st-norpie = pkgs.st-norpie;
        defaultApp = apps.st;
        defaultPackage = pkgs.st-norpie;

        devShell = pkgs.mkShell {
          nativeBuildInputs = libraries;
          buildInputs = with pkgs; [xorg.libX11 xorg.libXft gcc];
        };
      }
    );
}
