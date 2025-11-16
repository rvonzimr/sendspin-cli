{
  stdenv,
  unzip,
  autoPatchelfHook,
  fetchurl,
  qt5,
  libsForQt5,
  makeWrapper,
  writeScriptBin,
  bash,
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    wrapper = writeScriptBin "CASetupUtility" ''
      #!${bash}/bin/sh
      cd "$out/share/CASetupUtility"
      exec "$out/libexec/CASetupUtility" "$@"
    '';
  in
  {
    name = "CASetupUtility";
    version = "v1.55";
    src = builtins.trace "test" (fetchurl {
      url = "https://ebikes.ca/pub/media/downloadable/CA_Setup_Utility_${finalAttrs.version}_Linux.zip";
      hash = "sha256-lRBhbNI8fnVW92se53dgR8y8ftUEGHM5XHfl55KvTmM=";
    });

    buildInputs = [
      qt5.qtbase
      libsForQt5.qtserialport
      wrapper
    ];
    nativeBuildInputs = [
      unzip
      qt5.wrapQtAppsHook
      autoPatchelfHook
      #makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin

      cp CASetupUtility $out/bin/
      cp -r data $out/bin
    '';
  }
)
