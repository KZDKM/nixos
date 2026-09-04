{
  stdenv,
  kernel,
  pkgs,
  fetchFromGitHub,
  lib,
}:

let
  kallsyms-src = fetchFromGitHub {
    owner = "h33p";
    repo = "kallsyms-mod";
    rev = "master";
    sha256 = "sha256-E6Bc0AVNLUxJ98oRVbJXeQGI/MuuyL5487fsbNQokWY=";
  };
in
stdenv.mkDerivation rec {
  pname = "memflow-kmod";
  version = "0.2.1-unstable-2025-04-24";

  src = fetchFromGitHub {
    owner = "memflow";
    repo = "memflow-kvm";
    rev = "main";
    sha256 = "sha256-0bI6MPJszphcrl29LJdvTRTPY297svIIM7T3UH0WGWY=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = [
    kernel.moduleBuildDependencies

    pkgs.llvmPackages_19.clang-unwrapped
    pkgs.llvmPackages_19.lld
    pkgs.llvmPackages_19.llvm
    pkgs.llvmPackages_19.bintools-unwrapped
  ];

  postPatch = ''
      rm -rf memflow-kmod/kallsyms
      cp -r ${kallsyms-src} memflow-kmod/kallsyms
      chmod -R u+w memflow-kmod/kallsyms

      sed -i '1i#include <linux/version.h>' memflow-kmod/vmtools.c

      substituteInPlace memflow-kmod/vmtools.c --replace \
        'return mm_get_unmapped_area(data->wrapped_task->mm, data->wrapped_vma->vm_file, addr, len, pgoff + data->wrapped_vma->vm_pgoff, flags);' \
        '#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 13, 0)
        return mm_get_unmapped_area(data->wrapped_vma->vm_file, addr, len, pgoff + data->wrapped_vma->vm_pgoff, flags);
    #else
        return mm_get_unmapped_area(data->wrapped_task->mm, data->wrapped_vma->vm_file, addr, len, pgoff + data->wrapped_vma->vm_pgoff, flags);
    #endif'
  '';

  buildPhase = ''
    runHook preBuild
    make LLVM=1 \
      KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    KO_FILE=$(find . -name 'memflow.ko' -type f | head -1)
    if [ -z "$KO_FILE" ]; then
      echo "ERROR: memflow.ko not found. Tree:"
      find . -name '*.ko' -o -name '*.o' | head -30
      exit 1
    fi
    echo "Installing $KO_FILE"
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    cp "$KO_FILE" $out/lib/modules/${kernel.modDirVersion}/extra/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux kernel module for memflow's KVM connector";
    homepage = "https://github.com/memflow/memflow-kvm";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
