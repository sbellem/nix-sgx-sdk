#FROM nixpkgs/nix:nixos-19.09
#FROM nixpkgs/nix@sha256:4a35708f2014578f399719067714362a73c3a4d895dc070ced761044f3476631 as base

#FROM nixpkgs/nix:nixos-20.03
#FROM nixpkgs/nix@sha256:7c185d8de541589e7caa795a36aa9352fd8bd8a94ee298946433dedb7adeb315

#FROM nixpkgs/nix:nixos-20.09
#FROM nixpkgs/nix@sha256:9eee633905248e4800a308a5af38fcb5d58d9505dc6c1268196ae83757843a79

# nixpkgs/nix:latest
FROM nixpkgs/nix@sha256:c7ab99ed60cc587ac784742e2814303331283cca121507a1d4c0dd21ed1bdf83 as base

#RUN set -ex \
#        \
#        && mkdir /etc/nix \
#        && echo "sandbox = false" >> /etc/nix/nix.conf \
#        && nix-channel --add \
#            https://releases.nixos.org/nixos/20.03/nixos-20.03.3263.db46d7b20ad nixpkgs \
#        && nix-channel --update

WORKDIR /usr/src
COPY nix nix

FROM base as build
COPY sgxsdk.nix sgxsdk.nix
RUN nix-build --verbose 0 sgxsdk.nix
