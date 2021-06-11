{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "ippcrypto";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    rev = "6e1436a4dd3236a07f1c6cfba7b2eade1b82a1a3";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 6e1436a4dd3236a07f1c6cfba7b2eade1b82a1a3 sbellem linux-sgx
    sha256 = "0sr6109d589vq5xc7pig5752i9yk5dnlsr1ivj24y8l2vxr7gv6w";
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
  # sgx build uses the NIX_PATH ... see linux-sgx Makefile(s)
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    export NIX_PATH=nixpkgs=/nix/store/4lbr6as55rlgs7a73b06irrazimkg5jc-fake_nixpkgs
    '';
  buildPhase = ''
    runHook preBuild

    cd external/ippcp_internal/
    make
    
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
