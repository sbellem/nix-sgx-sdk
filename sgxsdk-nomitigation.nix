{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "sgxsdk-nomitigation";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    #rev = "d55fe39d6e5c1839623a51f8bcedddee68b0341b";
    rev = "328bb7c81eaed75bf53e214eda0411e86264171d";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 328bb7c81eaed75bf53e214eda0411e86264171d sbellem linux-sgx
    #sha256 = "1i945pvr6caibjmp7m3ax7wn6xhm7d5z7x5hi40c7gfqd8l5l3xr";
    sha256 = "1ij6csvcn66frqvnlv4r1vcspw7qlnzblghw7rfbbisx5xxfni6f";
    fetchSubmodules = true;
  };
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
  dontConfigure = true;
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    '';
  buildPhase = ''
    runHook preBuild

    cd external/ippcp_internal/
    make
    echo "DONE building IPP CRYPTO!"
    echo "ls -l ./inc"
    ls -l ./inc
    
    cd ../..
    make sdk_install_pkg_no_mitigation

    runHook postBuild
    '';
  postBuild = ''
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';
  dontInstall = true;
  dontFixup = true;
}
