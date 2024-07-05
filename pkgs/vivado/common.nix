# Unfortunately this only works for synthesis, not simulation, since
# /usr/bin/gcc is hardcoded in. Replacing all instances of "/usr/bin/gcc" with
# "gcc" doesn't work, so it seems like the path must be constructed at runtime.
#
# TODO:
# - Remove 'Add Design Tools or Devices' desktop entry, it's broken due to removing .xinstall (and would have crashed anyway when trying to modify the Nix store).
# - Try making a fake existing install of Vivado which already has the base modules that you don't want to install installed, so that this will work with the full tarball
#   - hey, I wonder if that would have the extra benefit of not expanding archives that are shared between modules twice?
# - define a proper interface instead of expecting people to know what all the modules and their dependencies are
# - one way to solve the issue of things assuming vivado's already been installed, while still retaining most of the benefits here, is to do a two-stage installation: always install the minimal version of vivado in the first stage, and then in the second stage install any bonus stuff.
#   since all the addons are way smaller than the base vivado installation, even though there'll be some duplicate work most of it will have already been done and so tweaking your extra modules will still be reasonably speedy.
#   it's also a hell of a lot more supported - we can simply use the .xinstall as intended (well, if we can manage to smuggle the archives into it anyway. haven't actually messed with that yet.)
#   - that would also fix the issue i've just discovered where only one module's stuff is showing up the in the 'Xilinx Design Tools' menu
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
  version = "2024.1";
  suffix = "0522_2023";

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

  moduleMap = builtins.listToAttrs (
    builtins.map (module: {
      name = module.configName;
      value = module;
    }) meta.modules
  );
  # Returns the names of all the modules another module loosely depends on, plus the module itself.
  looseRequiredModules =
    module:
    [ module.configName ]
    ++ builtins.concatLists (
      builtins.map (name: looseRequiredModules moduleMap.${name}) (module.looseDeps or [ ])
    );
  # Returns the names of all the modules another module tightly depends on, plus the module itself.
  tightRequiredModules =
    module:
    [ module.configName ]
    ++ builtins.concatLists (
      builtins.map (name: tightRequiredModules moduleMap.${name}) (module.tightDeps or [ ])
    );

  modules = builtins.filter (
    # Installing Vivado requires that at least one device is included in the
    # downloadRecord.dat; to avoid hardcoding one of them, include all the modules
    # that we can without accidentally installing something extra.
    otherMod:
    otherMod ? internalName
    && (
      module.allModules or false
      || otherMod.configName == module.configName
      || !(otherMod.base or false) && !(builtins.elem otherMod.configName (looseRequiredModules module))
    )
  ) meta.modules;
  modulesXml = lib.concatStrings (
    builtins.map (module: ''
      <entry>
        <key>${module.internalName}</key>
        <value>${module.configName}</value>
      </entry>
    '') modules
  );

  downloadRecord = writeText "download-record" ''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <installationRecord imageVersion="NA" originalVersion="${version}" version="${version}">
      <installedModules>
        ${modulesXml}
      </installedModules>
      <installedPackage>WebPACKEdition_Web</installedPackage>
      <installedProduct>VivadoProd</installedProduct>
    </installationRecord>
  '';

  archives = builtins.map requireArchive (lib.unique (module.archives ++ meta.xinstallArchives));
  archiveCmds = builtins.concatStringsSep "\n" (
    builtins.map (archive: "ln -s '${archive}' $out/payload/'${archive.name}'") archives
  );
  # TODO: I just noticed something about PAYLOAD_LOCATION_FROM_USER in the logs...
  # could we sidestep this?
  installer = runCommand "vivado-installer" { } ''
    mkdir $out
    ${lib.getExe xorg.lndir} ${xinstall} $out
    cp ${downloadRecord} $out/data/downloadRecord.dat
    mkdir $out/payload
    ${archiveCmds}
  '';

  modulesCfg = lib.concatStringsSep "," (
    builtins.map
      (
        otherMod:
        "${otherMod.configName}:${
          if builtins.elem otherMod.configName (tightRequiredModules module) then "1" else "0"
        }"
      )
      (
        builtins.filter (
          otherMod:
          otherMod.configName == module.configName
          # For some reason ISE refuses to install if the base modules are configured (in
          # either direction). It makes no sense, but it's not like configuring them has
          # any effect anyway so sure.
          || (!(otherMod.base or false) && !(module.ignoreHidden or false && otherMod.hidden or false))
        ) meta.modules
      )
  );
  debugFlag = lib.optionalString (module ? debug) "-x";
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

    ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c install_config.txt ${debugFlag}

    rm -rf $out/opt/Xilinx/.xinstall

    # Switch out the vendored JRE for our version, since for some reason Vivado's
    # version relies on /usr/share/fontconfig existing.
    for jre in $(find "$out/opt/Xilinx" -name 'jre*'); do
      rm -rf "$jre"
      ln -s ${temurin-jre-bin} "$jre"
    done

    if [ -e $out/opt/Xilinx/Vivado/${version}/lib/lnx64.o ]; then
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
    local exe
    while IFS= read -r -d "" exe; do
      isELF "$exe" || continue
      echo "patching $exe"
      patchelf --set-interpreter "$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)" "$exe" || true
    done < <(find "$out" -executable -type f -print0)

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
