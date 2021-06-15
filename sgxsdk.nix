{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "sgxsdk";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    rev = "68fed00c67532cf5be7df8dac5f9d13b3c25e9d8";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 68fed00c67532cf5be7df8dac5f9d13b3c25e9d8 sbellem linux-sgx
    sha256 = "08a6y35s3rlvhcbd8zxqkw7d5vknb5b3mw0wa1wis6y7av5pskx2";
    fetchSubmodules = true;
  };
  dontConfigure = true;
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
  dontInstall = true;
  postBuild = ''
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';
  dontFixup = true;
}
