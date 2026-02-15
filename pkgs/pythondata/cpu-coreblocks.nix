import ./common.nix {
  kind = "cpu";
  name = "coreblocks";
  hash = "sha256-we8dNzNltc0LGVJKPuJTUVG8m4JBC6vfzmvUgm1XwOE=";
  license = licenses: licenses.bsd3;
  # TODO: if we pre-install the deps, will pipx just use those instead of trying to fetch new ones?
  # (applies to minerva and sentinel too)
  dependencies = pkgs: [ pkgs.pipx ];
  # no test.py
  doCheck = false;
}
