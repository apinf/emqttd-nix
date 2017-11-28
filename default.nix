{ pkgs ? import <nixpkgs> {}}:
let overrides = rec {
  erlang = pkgs.beam.interpreters.erlangR19_nox;
  beamPackages = pkgs.beam.packages.erlangR19.override {
    inherit erlang;
  };
  relxExe = pkgs.callPackage ./relx.nix {};
};
  apinfEmqttd = pkgs.callPackage ./emqttd.nix (overrides // { withMqttBridge = false; });
  apinfEmqttdWithBridge = pkgs.callPackage ./emqttd.nix (overrides // { withMqttBridge = true; });
in { inherit apinfEmqttd apinfEmqttdWithBridge; }