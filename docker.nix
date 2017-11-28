{ pkgs ? import <nixpkgs> {}}:

with pkgs;

let image = {dockerTools, callPackage, ...}:
  let apinfEmqttd = callPackage ./default.nix {};
  in dockerTools.buildImage {
    name = "apinf/emqttd";
    tag = "latest";
    contents = [ apinfEmqttd pkgs.coreutils pkgs.gawk pkgs.gnused pkgs.bash pkgs.utillinux];
    runAsRoot = ''
      #!${stdenv.shell}
      ${dockerTools.shadowSetup}
      chmod -R u+w /opt/emqttd
      mkdir -p /root
      chmod -R u+w /root
    '';
    config = {
      Cmd = ["/opt/emqttd/bin/emqttd" "foreground"];
      Volumes = {
        "/opt/emqttd/etc" = {};
        "/opt/emqttd/data" = {};
        "/opt/emqttd/log" = {};
      };
      WorkingDir = "/opt/emqttd";
      ExposedPorts = let b = builtins;
                         ports' = {
                           mqtt = "1883";
                           mqtts = "8883";
                           ws = "8083";
                           wss = "8084";
                           dashboard = "18083";
                           epmd = "4369";
                         };
                         ports = b.attrValues ports';
                         erlangDistributionPorts = b.genList (x: b.toString(x+6000)) 999; 
                         allPorts = ports ++ erlangDistributionPorts;
                         makeAttrList = x: {name = "${x}/tcp"; value = {};};
                         attrList = b.map makeAttrList allPorts;
                         in b.listToAttrs attrList;
    };
  };
in
image pkgs
