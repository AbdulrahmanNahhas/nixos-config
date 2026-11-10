{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "shadow-rofi-mode";
  version = "1";
  src = ./rofi-mode.c;
  appsSource = ./apps.c;
  dontUnpack = true;
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [
    pkgs.rofi-unwrapped
    pkgs.glib
    pkgs.cairo
    pkgs.pango
  ];
  buildPhase = ''
    $CC -std=c11 -Wall -Wextra -Werror $appsSource \
      $(pkg-config --cflags --libs gio-unix-2.0) -o shadow-apps
    $CC -std=c11 -Wall -Wextra -Werror -fPIC -shared $src \
      $(pkg-config --cflags --libs rofi glib-2.0 pangocairo) -o shadow-menu.so
    $CC -std=c11 -Wall -Wextra -Werror -DSHADOW_MODE_TEST $src \
      $(pkg-config --cflags --libs rofi glib-2.0 pangocairo) -o check-mode
  '';
  doCheck = true;
  checkPhase = "./check-mode";
  installPhase = ''
    install -Dm755 shadow-apps $out/bin/shadow-apps
    install -Dm755 shadow-menu.so $out/lib/rofi/shadow-menu.so
  '';
}
