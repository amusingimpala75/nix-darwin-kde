final: prev: prev.lib.optionalAttrs prev.stdenv.isDarwin {
  kdePackages = prev.kdePackages.overrideScope (kfinal: kprev:
  let
    get-or-empty-attrs = attrs: name: if attrs ? ${name} then attrs.${name} else {};
    get-or-empty-list = attrs: name: if attrs ? ${name} then attrs.${name} else [];

    meta-platform-darwin = pkg: pkg.overrideAttrs (oldAttrs: {
      meta = (get-or-empty-attrs oldAttrs "meta") // {
        platforms = prev.lib.platforms.darwin;
      };
    });

    is-darwin = pkg:
    (!builtins.isNull pkg) &&
    (builtins.hasAttr "meta" pkg) &&
    (builtins.hasAttr "platforms" pkg.meta) &&
    (builtins.any (plat: builtins.elem plat prev.lib.platforms.darwin) pkg.meta.platforms);

    remove-non-darwin = pkgs: builtins.filter is-darwin pkgs;

    name-matches = pkg: name:
    (!builtins.isNull pkg) &&
    (builtins.hasAttr "pname" pkg) &&
    (pkg.pname == name);

    remove-all-names = to-remove: from: builtins.filter (pkg: !builtins.any (name: name-matches pkg name) to-remove) from;
    purge = pkgs: to-remove: remove-all-names to-remove (remove-non-darwin pkgs);

    to-darwin = pkg: (meta-platform-darwin pkg).overrideAttrs (oldAttrs: {
      buildInputs = (purge oldAttrs.buildInputs [
        "acl"
        "qtwayland"
      ]) ++ [
        kfinal.extra-cmake-modules
      ];
      nativebuildInputs = (get-or-empty-list oldAttrs "nativeBuildInputs") ++ [
        kprev.wrapQtAppsHook
      ];
      propagatedUserEnvPkgs = prev.lib.optionals (builtins.hasAttr "propagatedUserEnvPkgs" oldAttrs)
      (remove-non-darwin oldAttrs.propagatedUserEnvPkgs);
      propagatedBuildInputs = purge (get-or-empty-list oldAttrs "propagatedBuildInputs") [
        "packagekit-qt"
      ];
    });
  in {
    # Apps
    dolphin = (to-darwin kprev.dolphin).overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [
        kprev.qtsvg
      ];
    });
    kcalc = to-darwin kprev.kcalc;
    kcolorchooser = to-darwin kprev.kcolorchooser;
    kate = to-darwin kprev.kate;
    konsole = to-darwin kprev.konsole;
    okular = (to-darwin kprev.okular).overrideAttrs (oldAttrs: {
      cmakeFlags = oldAttrs.cmakeFlags ++ [
        "-DFORCE_NOT_REQUIRED_DEPENDENCIES=KF6DocTools"
      ];
    });

    # Frameworks / Libraries
    kcmutils = to-darwin kprev.kcmutils;
    knewstuff = to-darwin kprev.knewstuff;
    kcoreaddons = to-darwin kprev.kcoreaddons;
    ki18n = to-darwin kprev.ki18n;
    kdbusaddons = to-darwin kprev.kdbusaddons;
    kbookmarks = to-darwin kprev.kbookmarks;
    kconfig = to-darwin kprev.kconfig;
    kio = to-darwin kprev.kio;
    kparts = to-darwin kprev.kparts;
    solid = to-darwin kprev.solid;
    kiconthemes = to-darwin kprev.kiconthemes;
    kcompletion = to-darwin kprev.kcompletion;
    ktextwidgets = to-darwin kprev.ktextwidgets;
    knotifications = to-darwin kprev.knotifications;
    kcrash = to-darwin kprev.kcrash;
    kwindowsystem = to-darwin kprev.kwindowsystem;
    kwidgetsaddons = to-darwin kprev.kwidgetsaddons;
    kcodecs = to-darwin kprev.kcodecs;
    kguiaddons = to-darwin kprev.kguiaddons;
    karchive = (to-darwin kprev.karchive).overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ prev.bzip2 ];
    });
    kcolorscheme = to-darwin kprev.kcolorscheme;
    breeze-icons = to-darwin kprev.breeze-icons;
    sonnet = to-darwin kprev.sonnet;
    kservice = to-darwin kprev.kservice;
    kitemviews = to-darwin kprev.kitemviews;
    kjobwidgets = to-darwin kprev.kjobwidgets;
    kauth = to-darwin kprev.kauth;
    kconfigwidgets = to-darwin kprev.kconfigwidgets;
    kxmlgui = to-darwin kprev.kxmlgui;
    kpackage = to-darwin kprev.kpackage;
    attica = to-darwin kprev.attica;
    phonon = (to-darwin kprev.phonon).overrideAttrs (oldAttrs: {
      buildInputs = purge oldAttrs.buildInputs [
        "libpulseaudio"
      ];
    });
    ktexteditor = to-darwin kprev.ktexteditor;
    syntax-highlighting = to-darwin kprev.syntax-highlighting;
    knotifyconfig = to-darwin kprev.knotifyconfig;
    kpty = to-darwin kprev.kpty;
    threadweaver = to-darwin kprev.threadweaver;
    kwallet = to-darwin kprev.kwallet;
    libkexiv2 = to-darwin kprev.libkexiv2;
    purpose = to-darwin kprev.purpose;
    kirigami = (to-darwin kprev.kirigami).overrideAttrs (oldAttrs:
    let
      unwrapped = to-darwin kprev.kirigami.unwrapped;
    in {
      propagatedBuildInputs = [
        unwrapped
        kfinal.qqc2-desktop-style
      ];
      passthru = { inherit unwrapped; };
    });
    qqc2-desktop-style = to-darwin kprev.qqc2-desktop-style;

    extra-cmake-modules = meta-platform-darwin kprev.extra-cmake-modules;
  });
  # TODO: This has to be a bug in nix?
  # extra-cmake-modules = final.kdePackages.extra-cmake-modules;
}
