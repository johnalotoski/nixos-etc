{
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  binutils,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  fetchurl,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libappindicator-gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxslt,
  libxtst,
  makeShellWrapper,
  nspr,
  nss,
  pango,
  pipewire,
  # Runtime dependencies
  stdenv,
  systemdLibs,
  udev,
  wayland,
  xdg-utils,
  zstd,
}:
stdenv.mkDerivation {
  pname = "jumpcloud-password-manager";
  version = "3.3.34";

  src = fetchurl {
    url = "https://cdn.pwm.jumpcloud.com/DA/release/x64/JumpCloud-Password-Manager-latest.deb";
    hash = "sha256-XhWAqMQS/Q1O+9SICq/TMLiZjBjOPAjb5HO/FAoQJmo=";
  };

  nativeBuildInputs = [
    binutils
    makeShellWrapper
    zstd
    dpkg
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libappindicator-gtk3
    libdrm
    libgbm
    libGL
    libnotify
    libpulseaudio
    libsecret
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxkbfile
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxslt
    libxtst
    nspr
    nss
    pango
    pipewire
    stdenv.cc.cc
    systemdLibs
    udev
    wayland
  ];

  dontUnpack = true;
  dontPatchELF = true;

  installPhase = let
    rpath =
      lib.makeLibraryPath [
        alsa-lib
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libappindicator-gtk3
        libdrm
        libgbm
        libGL
        libnotify
        libpulseaudio
        libsecret
        libx11
        libxcb
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxkbcommon
        libxkbfile
        libxrandr
        libxrender
        libxscrnsaver
        libxshmfence
        libxtst
        nspr
        nss
        pango
        pipewire
        stdenv.cc.cc
        systemdLibs
        udev
        wayland
      ]
      + ":${lib.getLib stdenv.cc.cc}/lib64";
  in ''
    runHook preInstall

    # dpkg --fsys-tarfile avoids setuid issues with chrome-sandbox
    dpkg --fsys-tarfile $src | tar --extract
    rm -rf usr/share/lintian

    mkdir -p $out
    mv usr/* $out

    # Manual patchelf for all binaries and libraries
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/lib/jcpwm $file || true
    done

    # Create shell wrapper with Wayland support
    rm -f $out/bin/jcpwm
    makeShellWrapper $out/lib/jcpwm/jcpwm $out/bin/jcpwm \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --suffix PATH : ${lib.makeBinPath [xdg-utils]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [udev]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  meta = {
    description = "JumpCloud Password Manager Desktop App";
    homepage = "https://jumpcloud.com";
    # license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
