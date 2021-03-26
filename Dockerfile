#FROM nixpkgs/nix:nixos-20.03
FROM nixpkgs/nix@sha256:818dd239afef99a7ba0705af3de46fa093a0ef504391c2a1308283733b709b04

RUN set -ex \
        \
        && mkdir /etc/nix \
        && echo "sandbox = false" >> /etc/nix/nix.conf \
        && nix-channel --add \
            https://releases.nixos.org/nixos/20.03/nixos-20.03.3263.db46d7b20ad nixpkgs \
        && nix-channel --update

COPY shell.nix /usr/src/shell.nix
COPY sgxsdk.nix /usr/src/sgxsdk.nix
COPY nix /usr/src/nix

WORKDIR /usr/src
RUN nix-build shell.nix
