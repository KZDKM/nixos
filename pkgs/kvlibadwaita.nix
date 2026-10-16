{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  name = "kvlibadwaita-theme";
  src = fetchFromGitHub {
    owner = "GabePoel";
    repo = "KvLibadwaita";
    rev = "main";
    sha256 = "sha256-jCXME6mpqqWd7gWReT04a//2O83VQcOaqIIXa+Frntc=";
  };
  installPhase = ''
    mkdir -p $out/share/Kvantum/
    cp -r ./src/* $out/share/Kvantum
  '';
}
