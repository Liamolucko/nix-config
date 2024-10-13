# A general derivation for installing something using `xinstall`.
args@{
  lib,
  stdenv,
  requireFile,
  runCommand,
  glibc,
  temurin-jre-bin-21,
  xinstall,
  meta,
  modules ? [ ],
  archives ? [ ],
  debug ? false,
  postFixup ? "",
  passthru ? { },
  ...
}:
let
  requireArchive =
    basename:
    requireFile rec {
      name = "${basename}_${meta.version}_${meta.suffix}.xz";
      message = ''
        Xilinx's archives cannot be downloaded automatically as they are gated behind
        export control.

        To obtain them, you can either:
        - Use the `xinstall` package and select the 'Download Image (Install
          Separately)' option, then set 'Image Contents' to 'Selected Product Only',
          making sure to select a superset of the components you want to install.
        - Download and extract https://www.xilinx.com/member/forms/download/xef.html?filename=FPGAs_AdaptiveSoCs_Unified_${meta.version}_${meta.suffix}.tar.gz.

        The first option is recommended, since it requires significantly less download
        time / disk space.

        Then, run nix-store --add-fixed sha256 /path/to/download/payload/* to add all of
        the archives to the nix store.

        The specific archive that you are missing is ${name}.
      '';
      hash = meta.hashes.${basename};
    };

  mkPayload =
    archives:
    let
      archiveCmds = lib.concatStringsSep "\n" (
        lib.map (
          archiveName:
          let
            archive = requireArchive archiveName;
          in
          if lib.elem archiveName archives then
            "ln -s '${archive}' $out/'${archive.name}'"
          else
            "touch $out/'${archive.name}'"
        ) (lib.attrNames meta.hashes)
      );
    in
    runCommand "payload" { } ''
      mkdir -p $out
      ${archiveCmds}
    '';

  payload = mkPayload archives;

  modulesCfg = lib.concatStringsSep "," (
    lib.map (module: "${module}:${if lib.elem module modules then "1" else "0"}") (
      lib.attrNames (lib.filterAttrs (name: value: !(value.internal or false)) meta.modules)
    )
  );
  debugFlag = lib.optionalString debug "-x";

  timestampStrip = ''s/_[0-9]*\.\(desktop\|directory\)/\.\1/'';
in
stdenv.mkDerivation (
  {
    inherit (meta) pname version meta;
    # Copying this into the build directory provides the flexibility to alter the
    # `instRecord.dat` in archive tests, and also theoretically to set `xinstall` to
    # a tarball so that we don't need to store both the tarball and its contents in
    # the Nix store (e.g. if installing Petalinux or Vivado updates).
    src = xinstall;

    # We manually run the patchPhase after installation.
    dontPatch = true;

    installPhase = ''
      runHook preInstall

      cp ${./install_config.txt} install_config.txt
      substituteInPlace install_config.txt \
        --subst-var-by edition '${meta.edition}' \
        --subst-var-by product '${meta.product}' \
        --subst-var-by out $out/opt/Xilinx \
        --subst-var-by modules '${modulesCfg}'

      PAYLOAD_LOCATION_FROM_USER=${payload} ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c install_config.txt ${debugFlag}

      # For some reason Vivado puts its desktop entries and such into /build; copy
      # them into the right spot.
      if [ -e ../.local/share ]; then
        mkdir -p $out/share
        cp -r ../.local/share/* $out/share
      fi
      if [ -e ../.config ]; then
        mkdir -p $out/etc/xdg
        cp -r ../.config/* $out/etc/xdg
      fi

      runHook postInstall
    '';

    postFixup = ''
      # Switch out the vendored JRE for our version, since for some reason Vivado's
      # version relies on /usr/share/fontconfig existing.
      for jre in $(find "$out/opt/Xilinx" -name 'jre*'); do
        rm -rf "$jre"
        ln -s ${temurin-jre-bin-21} "$jre"
      done

      cd $out/opt/Xilinx
      patchPhase

      local exe
      while IFS= read -r -d "" exe; do
        isELF "$exe" || continue
        echo "patching $exe"
        patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 "$exe" || true
      done < <(find "$out" -executable -type f -print0)

      patchShebangs --host $out

      if [ -e $out/share ]; then
        # Get rid of desktop entries for modifying the installation, since they can't
        # modify the Nix store anyway.
        find $out/share/applications '(' -name "Uninstall*" -o -name "Add Design Tools or Devices*" ')' -delete
        sed -zi \
          's@ *<Include>\n *<Filename>\(Add Design Tools or Devices\|Uninstall\)[^<]*\.desktop</Filename>\n *</Include>\n@@g' \
          "$out/etc/xdg/menus/applications-merged/Xilinx Design Tools.menu"

        # Strip the timestamps off of Vivado's desktop entries to make it reproducible.
        find $out/share -type f \
          -exec bash -c 'mv "$0" "$(echo -n "$0" | sed "${timestampStrip}")"' '{}' ';'
        find $out/etc/xdg -type f \
          -exec sed -i "${timestampStrip}" '{}' ';'
      fi

      ${postFixup}
    '';

    passthru = {
      inherit mkPayload xinstall;
    } // passthru;
  }
  // (lib.removeAttrs args [
    "lib"
    "stdenv"
    "requireFile"
    "runCommand"
    "glibc"
    "temurin-jre-bin-21"
    "xinstall"
    "meta"
    "modules"
    "archives"
    "debug"
    "postFixup"
  ])
)
