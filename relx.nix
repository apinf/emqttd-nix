{stdenv, fetchurl}:
stdenv.mkDerivation rec {
  name = "relx-${version}";
  version = "v3.19.0";
  src = fetchurl {
    url = https://github.com/erlware/relx/releases/download/v3.19.0/relx;
    sha256 = "12bgjp31zljg6d6y5f3dxklqli7166337lpb951gacysfpl7vy0s";
  };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    mkdir -p $out/bin/
    cp $src $out/bin/relx
    chmod +x $out/bin/relx
    '';
}
