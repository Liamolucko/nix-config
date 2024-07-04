# Unfortunately this only works for synthesis, not simulation, since
# /usr/bin/gcc is hardcoded in. Replacing all instances of "/usr/bin/gcc" with
# "gcc" doesn't work, so it seems like the path must be constructed at runtime.
#
# TODO:
# - Remove 'Add Design Tools or Devices' desktop entry, it's broken due to removing .xinstall (and would have crashed anyway when trying to modify the Nix store).
# - Probably disable autostart for xic, or just remove it altogether
# - Update to 2024.1, obviously
{
  lib,
  stdenv,
  requireFile,
  runCommand,
  writeText,
  libxcrypt-legacy,
  makeWrapper,
  ncurses5,
  temurin-jre-bin,
  xinstall,
  xorg,
  zlib,
  module,
}:
let
  version = "2023.2";
  suffix = "1013_2256";

  meta = import ./meta.nix;
  requireArchive =
    basename:
    requireFile rec {
      name = "${basename}_${version}_${suffix}.xz";
      message = ''
        Xilinx's archives cannot be downloaded automatically as they are gated behind
        export control.

        To obtain them, you can either:
        - Use the `xinstall` package and select the 'Download Image (Install
          Separately)' option, then set 'Image Contents' to 'Selected Product Only',
          making sure to select a superset of the components you want to install.
        - Download and extract https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_${version}_${suffix}.tar.gz.

        The first option is recommended, since it requires significantly less download
        time / disk space.

        Then, run nix-store --add-fixed sha256 /path/to/download/payload/* to add all of
        the archives to the nix store.

        The specific archive that you are missing is ${name}.
      '';
      hash = meta.hashes.${basename};
    };

  archives = builtins.map requireArchive (lib.unique module.archives);
  downloadRecord = writeText "download-record" ''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <installationRecord imageVersion="NA" originalVersion="${version}" version="${version}">
      <installedModules>
        ${module.xml}
      </installedModules>
      <installedPackage>WebPACKEdition_Web</installedPackage>
      <installedProduct>VivadoProd</installedProduct>
    </installationRecord>
  '';

  archiveCmds = builtins.concatStringsSep "\n" (
    builtins.map (archive: "ln -s '${archive}' $out/payload/'${archive.name}'") archives
  );
  installer = runCommand "vivado-installer" { } ''
    mkdir $out
    ${lib.getExe xorg.lndir} ${xinstall} $out
    cp ${downloadRecord} $out/data/downloadRecord.dat
    mkdir $out/payload
    ${archiveCmds}
  '';

  modulesCfg = if module.configName != null then "${module.configName}:1" else "";
in
stdenv.mkDerivation rec {
  pname = "vivado-${module.name}";
  inherit version;
  src = installer;
  patches = if module ? patches then module.patches else [ ];

  # We invoke it manually in the fixup phase instead.
  dontPatch = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    cp ${./install_config.txt} install_config.txt
    substituteInPlace install_config.txt \
      --subst-var-by out $out/opt/Xilinx \
      --subst-var-by modules '${modulesCfg}'

    ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c install_config.txt

    rm -rf $out/opt/Xilinx/.xinstall

    # Switch out the vendored JRE for our version, since for some reason Vivado's
    # version relies on /usr/share/fontconfig existing.
    for jre in $(find "$out/opt/Xilinx" -name 'jre*'); do
      rm -rf "$jre"
      ln -s ${temurin-jre-bin} "$jre"
    done

    if [ -e $out/opt/Xilinx/Vivado/${version}/lib ]; then
      ln -s ${libxcrypt-legacy}/lib/libcrypt.so.1 $out/opt/Xilinx/Vivado/${version}/lib/lnx64.o
      ln -s ${ncurses5}/lib/libtinfo.so.5 $out/opt/Xilinx/Vivado/${version}/lib/lnx64.o
      ln -s ${xorg.libX11}/lib/libX11.so.6 $out/opt/Xilinx/Vivado/${version}/lib/lnx64.o
      ln -s ${zlib}/lib/libz.so.1 $out/opt/Xilinx/Vivado/${version}/lib/lnx64.o
    fi

    # For some reason Vivado puts its desktop entries and such into /build; copy
    # them into the right spot.
    if [ -e ../.local/share ]; then
      cp -r ../.local/share $out/share
    fi
    if [ -e ../.config ]; then
      mkdir $out/etc
      cp -r ../.config $out/etc/xdg
    fi

    if [ -e $out/opt/Xilinx/Vivado/${version}/bin ]; then
      mkdir $out/bin
      for exe in $(ls $out/opt/Xilinx/Vivado/${version}/bin); do
        if ! echo "$exe" | grep -E 'loader|unwrapped|.*\.sh'; then
          # We have to make wrappers instead of symlinks because Vivado looks for all its
          # stuff relative to the binary you're running, so putting them in the wrong spot
          # breaks it.
          makeWrapper "$out/opt/Xilinx/Vivado/${version}/bin/$exe" "$out/bin/$exe"
        fi
      done
    fi

    runHook postInstall
  '';

  postFixup = ''
    for exe in $(find $out -executable -type f); do
        isELF "$exe" || continue
        echo "patching $exe"
        patchelf --set-interpreter "$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)" "$exe" || true
    done

    cd $out/opt/Xilinx
    patchPhase
  '';

  meta = {
    description = "Design software for AMD adaptive SoCs and FPGAs";
    homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
