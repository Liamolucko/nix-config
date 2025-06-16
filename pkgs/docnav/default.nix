{ xinstall }:
xinstall.run {
  pname = "docnav";
  edition = "DocNav";
  product = "Documentation Navigator (Standalone)";

  modules = [
    "xinstall"
    "DocNav"
  ];
}
