{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  name = "fcitx5-theme";
  src = fetchFromGitHub {
    owner = "witt-bit";
    repo = "fcitx5-theme-macos12";
    rev = "main";
    sha256 = "sha256-H0X3+/mJ8KH73cZhv3ilNz77CBviQma4D2cKQ/iNiVM=";
  };
  installPhase = ''
    mkdir -p $out/share/fcitx5/themes
    cp -r ./* $out/share/fcitx5/themes
  '';
}
