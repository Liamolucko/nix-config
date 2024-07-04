{ callPackage, symlinkJoin }:
let
  meta = import ./meta.nix;
in
builtins.listToAttrs (
  builtins.map (module: {
    inherit (module) name;
    value = callPackage ./common.nix { inherit module; };
  }) meta.modules
)
// {
  # A customised version of symlinkJoin that replaces all the paths to the
  # original derivations in bin wrappers, desktop entries etc. with paths to the
  # joined derivation, since the whole point of joining modules together is so
  # that Vivado can see the newly-linked-in modules, which won't be the case if
  # you invoke it from directly within the base module where it has no knowledge
  # of the later joined derivation.
  joinModules =
    opts:
    let
      sedExprs = builtins.concatStringsSep " " (builtins.map (path: "-e s@'${path}'@$out@g") opts.paths);
    in
    symlinkJoin (
      opts
      // {
        postBuild =
          opts.postBuild or ""
          + ''
            find $out/{bin,share,etc} -type l -exec sed -i ${sedExprs} '{}' ';'
          '';
      }
    );
}
