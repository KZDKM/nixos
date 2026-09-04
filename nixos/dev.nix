{
  inputs,
  config,
  pkgs,
  pkgs-old,
  system,
  ...
}:
let
  python = pkgs.python313.override {
    self = python;
    packageOverrides = pyfinal: pyprev: {
      triton-library = pyfinal.callPackage ./packages/triton.nix { };
    };
  };

in
{
  environment.systemPackages = [
    pkgs.gnumake
    pkgs.gcc
    pkgs.clang-tools
    pkgs.iverilog
    pkgs.verible
    pkgs.z3
    pkgs.bitwuzla
    pkgs.capstone
    pkgs.rustup
    pkgs.llvmPackages.libclang
    pkgs.llvmPackages.clang
    (python.withPackages (
      python-pkgs: with python-pkgs; [
        pycryptodome
        unicorn
        triton-library
        z3-solver
        capstone
      ]
    ))
  ];
}
