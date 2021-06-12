{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "sgxsdk-nomitigation";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    #rev = "6e1436a4dd3236a07f1c6cfba7b2eade1b82a1a3";
    rev = "d55fe39d6e5c1839623a51f8bcedddee68b0341b";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev d55fe39d6e5c1839623a51f8bcedddee68b0341b sbellem linux-sgx
    #sha256 = "0sr6109d589vq5xc7pig5752i9yk5dnlsr1ivj24y8l2vxr7gv6w";
    sha256 = "1i945pvr6caibjmp7m3ax7wn6xhm7d5z7x5hi40c7gfqd8l5l3xr";
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
  # NIX_PATH=nixpkgs=/nix/store/h9gyw7rpm3m0n30xpyr1qgrsnrgh6zi0-fake_nixpkgs
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    export NIX_PATH=nixpkgs=/nix/store/4lbr6as55rlgs7a73b06irrazimkg5jc-fake_nixpkgs
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
