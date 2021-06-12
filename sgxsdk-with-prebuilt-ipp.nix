{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

let
  ipp_crypto = fetchurl {
    url = "https://download.01.org/intel-sgx/sgx-linux/2.13.3/optimized_libs_2.13.3.tar.gz";
    sha256 = "f46aceac799e546e5c01e484d7f7c01b34c1e1d79469600f86da2bd5b3ce7ad4";
  };

in
stdenvNoCC.mkDerivation {
  inherit ipp_crypto;
  name = "sgxsdk-with-prebuilt-ipp";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    rev = "6e1436a4dd3236a07f1c6cfba7b2eade1b82a1a3";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 6e1436a4dd3236a07f1c6cfba7b2eade1b82a1a3 sbellem linux-sgx
    #sha256 = "0sr6109d589vq5xc7pig5752i9yk5dnlsr1ivj24y8l2vxr7gv6w";
    #fetchSubmodules = true;
    sha256 = "1q2p4xcc80zml61y17f807fl162sjlclbvv8gmigkggc6xry6avn";
    #fetchSubmodules = true;
  };
  postUnpack = ''
    tar -C $sourceRoot -xvf $ipp_crypto
    '';
  dontConfigure = true;
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
    gcc
    gnumake
    texinfo
    bison
    flex
    python3
  ];
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    '';
  buildPhase = ''
    runHook preBuild

    make sdk_install_pkg

    runHook postBuild
    '';
  postBuild = ''
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';
  dontInstall = true;
  dontFixup = true;
}
