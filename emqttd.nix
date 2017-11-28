{ callPackage, beamPackages, fetchFromGitHub, withMqttBridge ? false, ...}@args:
let depset = beamPackages.callPackage ./deps.nix {};
    getSrc = { rev, sha256}: fetchFromGitHub {
    owner = "apinf";
    repo = "emq-relx";
    inherit rev sha256;
    };
    srcWithMqttBridge = getSrc {
    rev = "4be3d64d531340e48b3f6df2da34d658df28b915";
    sha256 = "1y7cmbnmfnc0xpz01wjh9as37s4h545rsiqzy4r301282qhzb2km";
  };
    srcWithoutMqttBridge = getSrc {
    rev = "ece5778d1dde731689c41902e0bc66744110ba82";
    sha256 = "128izjfvy57acms0mvfagp5s15p8h5cy9mqkzbi1mr2g5xqnsqfs";
  };
  commonOtpApps = with depset; [ emqttd emq_auth_pgsql emq_dashboard emq_plugin_elasticsearch ];
  paramsWithoutMqttBridge = {
    name = "apinf-emqttd";
    src = srcWithoutMqttBridge;
    beamDeps = commonOtpApps;
  };
  paramsWithMqttBridge = {
    name = "apinf-emqttd-with-bridge";
    src = srcWithMqttBridge;
    beamDeps = commonOtpApps ++ [ depset.mqtt_bridge ];
  };
  buildReleaseDrv = import ./emqttd-template.nix;
  drvParams = if withMqttBridge then paramsWithMqttBridge else paramsWithoutMqttBridge;
  releaseDrv = buildReleaseDrv drvParams;
 in
 callPackage releaseDrv args