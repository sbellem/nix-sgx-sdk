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
COPY ipp.nix ipp.nix

FROM base as build
RUN nix-build --quiet ipp.nix
