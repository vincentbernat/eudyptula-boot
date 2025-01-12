{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        eudyptula-boot-deps = with pkgs; [
          (busybox.override { enableAppletSymlinks = false; })
          coreutils
          qemu
          bintools
        ];
        minimal-configuration-deps = with pkgs; [
          coreutils
          gnumake
        ];
      in
      {
        packages = rec {
          eudyptula-boot = pkgs.writeShellApplication {
            name = "eudyptula-boot";
            runtimeInputs = eudyptula-boot-deps;
            text = ./eudyptula-boot;
          };
          minimal-configuration = pkgs.writeShellApplication {
            name = "minimal-configuration";
            runtimeInputs = minimal-configuration-deps;
            text = ./eudyptula-boot;
          };
          default = eudyptula-boot;
        };
        devShells.default = pkgs.mkShell {
          name = "eudyptula-boot";
          nativeBuildInputs = eudyptula-boot-deps ++ minimal-configuration-deps;
        };
      });
}
