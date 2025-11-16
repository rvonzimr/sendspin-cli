{
  stdenv,
  unzip,
  autoPatchelfHook,
  fetchurl,
  qt5,
  libsForQt5,
  pkgs,
  patchelf,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "CASetupUtility";
  version = "v1.55";
  src = fetchurl {
    url = "https://ebikes.ca/pub/media/downloadable/CA_Setup_Utility_${finalAttrs.version}_Linux.zip";
    hash = "sha256-lRBhbNI8fnVW92se53dgR8y8ftUEGHM5XHfl55KvTmM=";
  };

  patch_src = ./chdir_wrapper.c;
  theme_patch_src = ./theme_patch.cpp;
  light_theme = ./light-theme.qss;
  wrapper_src = ./wrapper.sh;
  forceQtStyle = "Breeze-light";

  buildInputs = [
    qt5.qtbase
    libsForQt5.qtserialport
    makeWrapper
  ];
  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    unzip
    autoPatchelfHook
    patchelf
    pkgs.gcc
  ];

  preBuildPhase = ''
    cp ${finalAttrs.patch_src} ./chdir_wrapper.c
    cp ${finalAttrs.theme_patch_src} ./theme_patch.cpp
  '';

  buildPhase = ''
    runHook preBuildPhase
    # Compile our shared library. The output file will be in the current directory.
    ${pkgs.gcc}/bin/gcc -fPIC -shared chdir_wrapper.c -o chdir_wrapper.so -ldl

    # Compile the new theme patch (C++), linking against the necessary Qt libs
    ${pkgs.gcc}/bin/g++ -fPIC -shared theme_patch.cpp -o theme_patch.so -ldl \
      -I${qt5.qtbase.dev}/include -L${qt5.qtbase}/lib -lQt5Core -lQt5Gui -lQt5Widgets
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/share/CASetupUtility $out/libexec

    cp CASetupUtility $out/libexec/
    cp chdir_wrapper.so $out/lib/
    cp theme_patch.so $out/lib/
    cp -r data $out/share/CASetupUtility/
    cp ${finalAttrs.light_theme} $out/share/CASetupUtility/light-theme.qss

    export qt_style="${finalAttrs.forceQtStyle}"

    patchelf \
      --add-needed chdir_wrapper.so \
      --add-needed theme_patch.so \
      $out/libexec/CASetupUtility

    substituteAll ${finalAttrs.wrapper_src} $out/bin/CASetupUtility
    chmod +x $out/bin/CASetupUtility
  '';

})
