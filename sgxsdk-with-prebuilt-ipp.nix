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
    rev = "e6036d6edb4371f2acc64c50b7cb51e9dfa439a4";
    sha256 = "0znallianv3lp3y62cfdgp8gacpw516qg8cjxhz8bj5lv5qghchk";
    fetchSubmodules = true;
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
