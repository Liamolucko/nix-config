{ callPackage }:
{
  xc7s50 = callPackage ./common.nix {
    family = "xc7";
    device = "xc7s50";
  };

  xc7a50t = callPackage ./common.nix {
    family = "xc7";
    device = "xc7a50t";
  };
  xc7a100t = callPackage ./common.nix {
    family = "xc7";
    device = "xc7a100t";
  };
  xc7a200t = callPackage ./common.nix {
    family = "xc7";
    device = "xc7a200t";
  };

  xc7z010 = callPackage ./common.nix {
    family = "xc7";
    device = "xc7z010";
  };
  xc7z020 = callPackage ./common.nix {
    family = "xc7";
    device = "xc7z020";
  };

  ql-eos-s3 = callPackage ./common.nix {
    # Internally the family is pp3, but f4pga expects eos-s3 so use that.
    family = "eos-s3";
    device = "ql-eos-s3";
  };
  ql-pp3e = callPackage ./common.nix {
    # TODO: no idea what this one's family should be
    family = "pp3";
    device = "ql-pp3e";
  };

  # TODO: these names are disgusting, should we alter them?
  qlf_k4n8-qlf_k4n8_umc22_fast = callPackage ./common.nix {
    family = "qlf_k4n8";
    device = "qlf_k4n8-qlf_k4n8_umc22_fast";
  };
  # TODO: no idea if this is truly a separate device
  qlf_k4n8-qlf_k4n8_umc22_slow = callPackage ./common.nix {
    family = "qlf_k4n8";
    device = "qlf_k4n8-qlf_k4n8_umc22_slow";
  };

  # f4pga-arch-defs also contains support for ice40 devices, but has no way to
  # install them. But f4pga just uses nextpnr for ice40 anyway, so it doesn't
  # really matter.
}
