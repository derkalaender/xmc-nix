{
  lib,
  stdenv,
  dpkg,
}: let
  version = (import ./version.nix).version;
in
  stdenv.mkDerivation {
    pname = "xmclib";
    inherit version;

    src = ./xmclib-${version}.deb;

    nativeBuildInputs = [
      dpkg
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt
      mv ./* $out

      runHook postInstall
    '';

    meta = {
      description = "The XMC Peripheral Library (XMCLib) consists of low-level drivers for the XMC product family peripherals.";
      homepage = "https://github.com/Infineon/mtb-xmclib-cat3";
      license = with lib.licenses; [bsd3];
      platforms = ["x86_64-linux"];
    };
  }
