{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  description = "bw-key";

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustVersion = pkgs.rust-bin.stable.latest.default;

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustVersion;
          rustc = rustVersion;
        };

        myRustBuild = rustPlatform.buildRustPackage {
          pname =
            "bw-key"; # make this what ever your cargo.toml package.name is
          version = "0.1.1";
          src = ./.; # the folder with the cargo.toml
          nativeBuildInputs = [ pkgs.pkg-config pkgs.perl]; # just for the host building the package
          buildInputs = [ pkgs.openssl ]; # packages needed by the consumer
          cargoLock.lockFile = ./Cargo.lock;
          doCheck = false;
        };
      in
      {
        defaultPackage = myRustBuild;
        default = self.defaultPackage;
        devShell = pkgs.mkShell {
          buildInputs =
            [ (rustVersion.override { extensions = [ "rust-src" ]; }) pkgs.pkg-config pkgs.openssl pkgs.perl ];
        };
      });

}
