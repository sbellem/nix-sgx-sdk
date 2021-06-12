{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

stdenvNoCC.mkDerivation {
  name = "sgxsdk";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    rev = "d55fe39d6e5c1839623a51f8bcedddee68b0341b";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev d55fe39d6e5c1839623a51f8bcedddee68b0341b sbellem linux-sgx
    sha256 = "1i945pvr6caibjmp7m3ax7wn6xhm7d5z7x5hi40c7gfqd8l5l3xr";
    fetchSubmodules = true;
  };
  dontConfigure = true;
  preBuild = ''
    export BINUTILS_DIR=$binutils/bin
    export NIX_PATH=nixpkgs=/nix/store/4lbr6as55rlgs7a73b06irrazimkg5jc-fake_nixpkgs
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
    make clean; make
    make clean; make MITIGATION-CVE-2020-0551=LOAD
    make clean; make MITIGATION-CVE-2020-0551=CF
    cd ../..

    make sdk_install_pkg

    runHook postBuild
    '';
  dontInstall = true;
  postBuild = ''
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';
  dontFixup = true;
  shellHook = ''echo "SGX SDK enviroment"'';
}
