{ stdenv, fetchFromGitHub, relxExe, beamPackages,
  depset ? beamPackages.callPackage ./deps.nix {},
  ...}:

let b = builtins;
  depset' = b.removeAttrs depset ["override" "overrideDerivation"];
  deps = b.attrValues depset';
in beamPackages.buildErlangMk rec {
  name = "apinf-emqttd";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "apinf";
    repo = "emq-relx";
    rev = "ece5778d1dde731689c41902e0bc66744110ba82";
    sha256 = "128izjfvy57acms0mvfagp5s15p8h5cy9mqkzbi1mr2g5xqnsqfs";
  };
  beamDeps = with depset; [ emqttd emq_auth_pgsql emq_dashboard emq_plugin_elasticsearch];
  # the project expects relx in folder, will download if missing
  patchPhase = ''
    runHook prePatch
    ln -s ${relxExe}/bin/relx
    mkdir -p deps
    cp --no-preserve=mode -R ${depset.emqttd}/lib/erlang/lib/emqttd* deps/emqttd
    cp --no-preserve=mode -R ${depset.emq_dashboard}/lib/erlang/lib/emq_dashboard* deps/emq_dashboard
    cp --no-preserve=mode -R ${depset.emq_plugin_elasticsearch}/lib/erlang/lib/emq_plugin_elasticsearch* deps/emq_plugin_elasticsearch
    cp --no-preserve=mode -R ${depset.emq_auth_pgsql}/lib/erlang/lib/emq_auth_pgsql* deps/emq_auth_pgsql
    runHook postPatch
  '';
  # Since this does not build an otp app the default installPhase won't work
  # Let's override it to copy the release instead.
  installPhase = ''
  runHook preInstall

  substituteInPlace _rel/emqttd/etc/plugins/emq_auth_pgsql.conf --replace root postgres
  substituteInPlace _rel/emqttd/etc/plugins/emq_auth_pgsql.conf --replace 127.0.0.1 postgres
  substituteInPlace _rel/emqttd/etc/plugins/emq_plugin_elasticsearch.conf --replace localhost elasticsearch

  mkdir -p $out/opt
  cp -r _rel/emqttd $out/opt/

  runHook postInstall
  '';
}
