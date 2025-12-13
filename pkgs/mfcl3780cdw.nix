{
  coreutils,
  dpkg,
  fetchurl,
  ghostscript,
  gnugrep,
  gnused,
  lib,
  makeWrapper,
  perl,
  pkgsi686Linux,
  stdenv,
  which,
}: let
  model = "mfcl3780cdw";
  version = "3.5.1-1";
  src = fetchurl {
    url = "https://download.brother.com/pub/com/linux/linux/packages/${model}pdrv-${version}.i386.deb";
    sha256 = "sha256-CXOwg2V4wMO1UpiwcEaobVxX7qnXEY0g8Gz7aLw1/+w=";
  };
  reldir = "opt/brother/Printers/${model}/";
in rec {
  driver = stdenv.mkDerivation rec {
    inherit src version;
    name = "${model}drv-${version}";

    nativeBuildInputs = [
      dpkg
      makeWrapper
    ];

    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
        dir="$out/${reldir}"
        substituteInPlace $dir/lpd/filter_${model} \
          --replace /usr/bin/perl ${perl}/bin/perl \
          --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir\"; #" \
          --replace "PRINTER =~" "PRINTER = \"${model}\"; #"
        wrapProgram $dir/lpd/filter_${model} \
          --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          ghostscript
          gnugrep
          gnused
          which
        ]
      }
      patchelf --set-interpreter "${pkgsi686Linux.stdenv.cc.libc}/lib/ld-linux.so.2" \
        $dir/lpd/i686/brmfcl3780cdwfilter

      patchelf --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
        $dir/lpd/x86_64/brmfcl3780cdwfilter
    '';

    meta = {
      description = "Brother ${lib.strings.toUpper model} driver";
      homepage = "http://www.brother.com/";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      license = lib.licenses.unfree;
      platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      maintainers = [lib.maintainers.steveej];
    };
  };

  cupswrapper = stdenv.mkDerivation rec {
    inherit version src;
    name = "${model}cupswrapper-${version}";

    nativeBuildInputs = [
      dpkg
      makeWrapper
    ];

    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      basedir=${driver}/${reldir}
      dir=$out/${reldir}
      substituteInPlace $dir/cupswrapper/brother_lpdwrapper_${model} \
        --replace /usr/bin/perl ${perl}/bin/perl \
        --replace "basedir =~" "basedir = \"$basedir\"; #" \
        --replace "PRINTER =~" "PRINTER = \"${model}\"; #"
      wrapProgram $dir/cupswrapper/brother_lpdwrapper_${model} \
        --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnugrep
          gnused
        ]
      }
      mkdir -p $out/lib/cups/filter
      mkdir -p $out/share/cups/model
      ln $dir/cupswrapper/brother_lpdwrapper_${model} $out/lib/cups/filter
      ln $dir/cupswrapper/brother_${model}_printer_en.ppd $out/share/cups/model
    '';

    meta = {
      description = "Brother ${lib.strings.toUpper model} CUPS wrapper driver";
      homepage = "http://www.brother.com/";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      license = lib.licenses.gpl2Plus;
      platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
      maintainers = [];
    };
  };
}
