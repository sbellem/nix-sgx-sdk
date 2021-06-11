#FROM nixpkgs/nix:nixos-19.09
FROM nixpkgs/nix@sha256:4a35708f2014578f399719067714362a73c3a4d895dc070ced761044f3476631 as base

#FROM nixpkgs/nix:nixos-20.03
#FROM nixpkgs/nix@sha256:7c185d8de541589e7caa795a36aa9352fd8bd8a94ee298946433dedb7adeb315

#FROM nixpkgs/nix:nixos-20.09
#FROM nixpkgs/nix@sha256:9eee633905248e4800a308a5af38fcb5d58d9505dc6c1268196ae83757843a79

# latest/unstable
#FROM nixpkgs/nix@sha256:00ee859d3137c168c83c17cd1263f751f160fb365b1068391e6f5c991184824d

#RUN set -ex \
#        \
#        && mkdir /etc/nix \
#        && echo "sandbox = false" >> /etc/nix/nix.conf \
#        && nix-channel --add \
#            https://releases.nixos.org/nixos/20.03/nixos-20.03.3263.db46d7b20ad nixpkgs \
#        && nix-channel --update

COPY nix /usr/src/nix
RUN echo $NIX_PATH
WORKDIR /usr/src

FROM base as ipp
COPY ipp.nix ipp.nix
RUN nix-build ipp.nix

FROM base as sgxsdk
COPY sgxsdk.nix sgxsdk.nix
RUN nix-build sgxsdk.nix

FROM base as sgxsdk-with-prebuilt-ipp
COPY sgxsdk-with-prebuilt-ipp.nix sgxsdk-with-prebuilt-ipp.nix
RUN nix-build sgxsdk-with-prebuilt-ipp.nix
