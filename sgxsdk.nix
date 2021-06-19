{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "sgxsdk";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 68fed00c67532cf5be7df8dac5f9d13b3c25e9d8 sbellem linux-sgx
    rev = "e6036d6edb4371f2acc64c50b7cb51e9dfa439a4";
    sha256 = "0znallianv3lp3y62cfdgp8gacpw516qg8cjxhz8bj5lv5qghchk";
    fetchSubmodules = true;
  };
  dontConfigure = true;
  prePatch = ''
    patchShebangs ./linux/installer/bin/build-installpkg.sh
    patchShebangs ./linux/installer/common/sdk/createTarball.sh
    patchShebangs ./linux/installer/common/sdk/install.sh
    '';
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    '';
  #nativeBuildInputs = [ gcc, gnum4 ];
  buildInputs = [
    binutils
    autoconf
    automake
    libtool
    ocaml
    ocamlPackages.ocamlbuild
    file
    cmake
    git
    gnum4
    openssl
    perl
    #glibc
    gcc
    gnumake
    texinfo
    bison
    flex
    python3
    nasm
  ];
  buildPhase = ''
    runHook preBuild

    cd external/ippcp_internal/
    make
    make clean
    make MITIGATION-CVE-2020-0551=CF
    make clean
    make MITIGATION-CVE-2020-0551=LOAD
    cd ../..

    make sdk_install_pkg

    runHook postBuild
    '';
  postBuild = ''
    patchShebangs ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';
  installPhase = ''
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';
  dontFixup = true;
}
