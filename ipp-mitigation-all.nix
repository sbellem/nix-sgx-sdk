{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "ippcrypto-mitigation-load";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    rev = "328bb7c81eaed75bf53e214eda0411e86264171d";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 328bb7c81eaed75bf53e214eda0411e86264171d sbellem linux-sgx
    sha256 = "1ij6csvcn66frqvnlv4r1vcspw7qlnzblghw7rfbbisx5xxfni6f";
    fetchSubmodules = true;
  };
  buildInputs = [
    binutils
    autoconf
    automake
    libtool
    ocaml
    ocamlPackages.ocamlbuild
    file
    cmake
    gnum4
    openssl
    gcc
    gnumake
    texinfo
    bison
    flex
    perl
    python3
    git
    nasm
  ];
  dontConfigure = true;
  # sgx expects binutils to be under /usr/local/bin by default
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    '';
  buildPhase = ''
    runHook preBuild

    cd external/ippcp_internal/
    make MITIGATION-CVE-2020-0551=LOAD
    make clean
    make MITIGATION-CVE-2020-0551=CF
    
    runHook postBuild
    '';
  postBuild = ''
    mkdir -p $out
    cp -r ./lib $out/lib
    cp -r ./inc $out/inc
    cp -r ./license $out/license
    ls -l ./inc/
  '';
  dontInstall = true;
  dontFixup = true;
}
