{
  cairo = {
    dependencies = ["native-package-installer" "pkg-config" "red-colors"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a85gisjb2n236bpay7cjqlxq07m4swc8mqnwy8c5rkxfhil194c";
      type = "gem";
    };
    version = "1.17.13";
  };
  cairo-gobject = {
    dependencies = ["cairo" "glib2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13xyy7ykahly1c5wqwx3p1bwwvf9fz131jd48zmx0r6xfr31q5aa";
      type = "gem";
    };
    version = "4.2.2";
  };
  fiddle = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x504023g56y32r81l6i4pqbhn46szzy6s5bcdlc7kb5iv1iigar";
      type = "gem";
    };
    version = "1.1.2";
  };
  gdk_pixbuf2 = {
    dependencies = ["gio2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06knn59yspwffl81s5w55j8944jvnqy64v0h2401cj871ajxd8jn";
      type = "gem";
    };
    version = "4.2.2";
  };
  gio2 = {
    dependencies = ["fiddle" "gobject-introspection"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00m1v9diw0bcas8hgd0vgahr73mnp7j4dfvnxvykvnprmnr0szz6";
      type = "gem";
    };
    version = "4.2.2";
  };
  glib2 = {
    dependencies = ["native-package-installer" "pkg-config"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0li06a5s62dfpdvabb6z7jwgjs08c6v50hv65z2pz53w9bv8m5cq";
      type = "gem";
    };
    version = "4.2.2";
  };
  gobject-introspection = {
    dependencies = ["glib2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x803rl46p826c92xpnr0qm04n8m0ckssd02vdnrlf562l01jnsq";
      type = "gem";
    };
    version = "4.2.2";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b4qsi8gay7ncmigr0pnbxyb17y3h8kavdyhsh7nrlqwr35vb60q";
      type = "gem";
    };
    version = "2.7.2";
  };
  matrix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      type = "gem";
    };
    version = "0.4.2";
  };
  native-package-installer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bvr9q7qwbmg9jfg85r1i5l7d0yxlgp0l2jg62j921vm49mipd7v";
      type = "gem";
    };
    version = "1.1.9";
  };
  observer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b2h1642jy1xrgyakyzz6bkq43gwp8yvxrs8sww12rms65qi18yq";
      type = "gem";
    };
    version = "0.1.2";
  };
  optimist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q4jqq3v1bxlfr9jgqmahnygkvl81lr6s1rhm8qg66c9xr9nz241";
      type = "gem";
    };
    version = "3.1.0";
  };
  parslet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01pnw6ymz6nynklqvqxs4bcai25kcvnd5x4id9z3vd1rbmlk0lfl";
      type = "gem";
    };
    version = "2.0.0";
  };
  pkg-config = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04wi7n51w42v9s958gfmxwkg5iikq25whacyflpi307517ymlaya";
      type = "gem";
    };
    version = "1.5.6";
  };
  red-colors = {
    dependencies = ["json" "matrix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16lj0h6gzmc07xp5rhq5b7c1carajjzmyr27m96c99icg2hfnmi3";
      type = "gem";
    };
    version = "0.4.0";
  };
  rmagick = {
    dependencies = ["observer" "pkg-config"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qa11i72j76q2v8lbvls3a8dqvkh9v3sgbd9mv9g2rqvb8gqkjrp";
      type = "gem";
    };
    version = "6.0.1";
  };
  rsvg2 = {
    dependencies = ["cairo-gobject" "gdk_pixbuf2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12whpb6a9rzmmzh0zayxk9rlyfpd462zxk2vw1vp35jr675mg2n0";
      type = "gem";
    };
    version = "4.2.2";
  };
  rsyntaxtree = {
    dependencies = ["optimist" "parslet" "rmagick" "rsvg2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06dz9i9yw3giwy7gc7j4f0chgydm33wwwirgsciczhf0x2z1bj7p";
      type = "gem";
    };
    version = "1.2.12";
  };
}
