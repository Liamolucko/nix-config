{
  bundlerApp,
  defaultGemConfig,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  librsvg,
  pkg-config,
  wrapGAppsNoGuiHook,
}:
bundlerApp {
  pname = "rsyntaxtree";
  gemdir = ./.;
  exes = [ "rsyntaxtree" ];

  gemConfig = defaultGemConfig // {
    rsvg2 = attrs: { nativeBuildInputs = [ pkg-config ]; };
  };

  nativeBuildInputs = [ wrapGAppsNoGuiHook ];
  buildInputs = [
    gdk-pixbuf
    glib.out
    gobject-introspection
    librsvg
  ];
  # `bundlerApp` doesn't run the fixup phase, so do it manually.
  postBuild = ''
    for phase in $preFixupPhases; do
      $phase
    done
    fixupPhase
  '';
}
