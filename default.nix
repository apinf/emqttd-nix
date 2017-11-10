{ pkgs ? import <nixpkgs> {}}:

pkgs.callPackage ./emqttd.nix {
  erlang = pkgs.beam.interpreters.erlangR19_nox;
  beamPackages = pkgs.beam.packages.erlangR19.override {
    erlang = pkgs.beam.interpreters.erlangR19_nox;
  };
  relxExe = pkgs.callPackage ./relx.nix {};
}
