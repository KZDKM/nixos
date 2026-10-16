{
  pkgs,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "triton-library";
  version = "0.9";
  src = fetchFromGitHub {
    owner = "JonathanSalwan";
    repo = "Triton";
    rev = "4f7ddb77c63d4d651f2e906c8bbece630103d475";
    sha256 = "sha256-gZV1UoG8tYnu4SgzubNaSBlX/MnEfC6maJcnD574SNQ=";
  };
  doCheck = false;

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.python313
  ];

  buildInputs = [
    pkgs.z3
    pkgs.boost
    pkgs.capstone
    pkgs.llvmPackages.llvm
  ];
  cmakeFlags = [
    "-DLLVM_INTERFACE=ON"
    # These help CMake find the right LLVM
    "-DCMAKE_PREFIX_PATH=${pkgs.llvmPackages.llvm}/lib/cmake/llvm"
    # Optional but recommended:
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  installPhase = ''
    runHook preInstall
    make install
    runHook postInstall
  '';

  format = "other";
}
