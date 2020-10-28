# nix-sgx-sdk
Experimental nix derivation for Intel's SGX SDK.

This a work-in-progress.

## Quick start
Build the image and work in a container:

```shell
$ docker-compose build
$ docker-compose run --rm nix-sgx-sdk
```

Build and install the SGX SDK (this will take some time):

```shell
bash-4.4# nix-build shell.nix

...

Installation is successful! The SDK package can be found in /nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk

Please set the environment variables with below command:

source /nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/environment
/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx
```

The sdk is also under `/usr/src/result`:

```shell
bash-4.4# ls result/sgxsdk/
SampleCode  bin  buildenv.mk  environment  include  lib64  licenses  pkgconfig  sdk_libs  uninstall.sh
```

Source the SGX SDK environment:
```shell
bash-4.4# source result/sgxsdk/environment
```

Let's build a signed enclave, for the `SampleEnclave` example:

```shell
bash-4.4# cd result/sgxsdk/SampleCode/SampleEnclave
```

In order to use `make` we need to go into a `nix-shell` session because `make`
is not installed on the system.

```shell
bash-4.4# nix-shell /usr/src/shell.nix
SGX SDK enviroment
```

Build the signed enclave:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# make enclave.signed.so
GEN  =>  Enclave/Enclave_t.h
CC   <=  Enclave/Enclave_t.c
CXX  <=  Enclave/Edger8rSyntax/Arrays.cpp
CXX  <=  Enclave/Edger8rSyntax/Functions.cpp
CXX  <=  Enclave/Edger8rSyntax/Pointers.cpp
CXX  <=  Enclave/Edger8rSyntax/Types.cpp
CXX  <=  Enclave/Enclave.cpp
CXX  <=  Enclave/TrustedLibrary/Libc.cpp
CXX  <=  Enclave/TrustedLibrary/Libcxx.cpp
CXX  <=  Enclave/TrustedLibrary/Thread.cpp
LINK =>  enclave.so
<EnclaveConfiguration>
    <ProdID>0</ProdID>
    <ISVSVN>0</ISVSVN>
    <StackMaxSize>0x40000</StackMaxSize>
    <HeapMaxSize>0x100000</HeapMaxSize>
    <TCSNum>10</TCSNum>
    <TCSPolicy>1</TCSPolicy>
    <!-- Recommend changing 'DisableDebug' to 1 to make the enclave undebuggable for enclave release -->
    <DisableDebug>0</DisableDebug>
    <MiscSelect>0</MiscSelect>
    <MiscMask>0xFFFFFFFF</MiscMask>
</EnclaveConfiguration>
tcs_num 10, tcs_max_num 10, tcs_min_pool 1
The required memory is 4059136B.
The required memory is 0x3df000, 3964 KB.
Succeed.
SIGN =>  enclave.signed.so
```

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# sha256sum enclave.signed.so
4328970ec560704b259a301979f0c4963718b0a4e55d313cce070d2589dfdd0b  enclave.signed.so
```

Compile and run the local attestation sample in simulation mode:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode]# cd LocalAttestation/
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation]# make SGX_MODE=SIM

...

LINK => libenclave_responder.so
<EnclaveConfiguration>
    <ProdID>1</ProdID>
    <ISVSVN>0</ISVSVN>
    <StackMaxSize>0x40000</StackMaxSize>
    <HeapMaxSize>0x100000</HeapMaxSize>
    <TCSNum>1</TCSNum>
    <TCSPolicy>1</TCSPolicy>
    <!-- Recommend changing 'DisableDebug' to 1 to make the enclave undebuggable for enclave release -->
    <DisableDebug>0</DisableDebug>
    <MiscSelect>0</MiscSelect>
    <MiscMask>0xFFFFFFFF</MiscMask>
</EnclaveConfiguration>
tcs_num 1, tcs_max_num 1, tcs_min_pool 1
The required memory is 1994752B.
The required memory is 0x1e7000, 1948 KB.
Succeed.
SIGN =>  libenclave_responder.signed.so
make[1]: Leaving directory '/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/SampleCode/LocalAttestation/EnclaveResponder'
make[1]: Entering directory '/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/SampleCode/LocalAttestation/App'
CC   <=  EnclaveInitiator_u.c
CC   <=  EnclaveResponder_u.c
CC   <=  UntrustedEnclaveMessageExchange.cpp
CXX   <=  App.cpp
GEN  =>  app
make[1]: Leaving directory '/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/SampleCode/LocalAttestation/App'
The project has been built in simulation debug mode.
```

Run the app:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation]# cd bin/
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation/bin]# ./app
succeed to load enclaves.
succeed to establish secure channel.
Succeed to exchange secure message...
Succeed to close Session...
```

The same commands can be used with the other samples.


## Rust SGX SDK
As an example of reproducing an enclave build, for an application based on
the [Rust SGX SDK](https://github.com/apache/incubator-teaclave-sgx-sdk),
let's build the enclave of the
[`helloworld`](https://github.com/apache/incubator-teaclave-sgx-sdk/tree/master/samplecode/helloworld) sample.

**NOTE**: *The steps that follow could be simplified and further automated,
thus reducing the number of manual steps currently required. Future
improvements should make it simpler.*

First build the image:

```shell
$ docker-compose build nix-rust-sgx-sdk
```

Launch a container:

```shell
$ docker-compose run --rm nix-rust-sgx-sdk
```

Once in the container, start a `nix-shell` session:

```shell
bash-4.4# nix-shell rust-sgx-sdk.nix
```

Unpack the Rust SGX SDK source code:

```shell
[nix-shell:/usr/src]# unpackPhase
unpacking source archive /nix/store/msvp3cfv2d8h0r9dhb2mqypkhil0nzra-source
source root is source
```

Go into the directory where the Rust SGX SDK source code has been unpacked,
and build the enclave:

```shell
[nix-shell:/usr/src]# cd source/
[nix-shell:/usr/src/source]# buildPhase

...

GEN  =>  enclave/Enclave_t.c enclave/Enclave_t.h app/Enclave_u.c app/Enclave_u.h
CC   <=  enclave/Enclave_t.c
LINK =>  enclave/enclave.so
mkdir -p bin
<!-- Please refer to User's Guide for the explanation of each field -->
<EnclaveConfiguration>
    <ProdID>0</ProdID>
    <ISVSVN>0</ISVSVN>
    <StackMaxSize>0x40000</StackMaxSize>
    <HeapMaxSize>0x100000</HeapMaxSize>
    <TCSNum>1</TCSNum>
    <TCSPolicy>1</TCSPolicy>
    <DisableDebug>0</DisableDebug>
    <MiscSelect>0</MiscSelect>
    <MiscMask>0xFFFFFFFF</MiscMask>
</EnclaveConfiguration>
tcs_num 1, tcs_max_num 1, tcs_min_pool 1
The required memory is 1601536B.
The required memory is 0x187000, 1564 KB.
Succeed.
SIGN =>  bin/enclave.signed.so
```

This will result in an enclave build under `enclave/enclave.so` and a signed
enclave under `bin/enclave.signed.so`.

If the "reproducibility" works as it should, then one should obtain the
following sha256 hashes for the `enclave.so` and `enclave.signed.so` files.

Unsigned enclave sha256:

```shell
[nix-shell:/usr/src/source/samplecode/helloworld]# sha256sum enclave/enclave.so
40d525874fa68ee1fe75235fab21f0130045f947fa41225226896f22b06ec2a6  enclave/enclave.so
```

Signed enclave sha256:

```shell
[nix-shell:/usr/src/source/samplecode/helloworld]# sha256sum bin/enclave.signed.so
7f447257097f9375c0fbff0c236f486a033c341d5bb4e8f4bd795377e895eb9c  bin/enclave.signed.so
```

The above build phase used the private key provided by the sample code to sign
the enclave. This private key is under `enclave/Enclave_private.pem`.

To use a different key, one can copy the preferred key to replace
`enclave/Enclave_private.pem`, and run `buildPhase`, as shown above.

For instance:

```shell
cp /usr/src/keys/Developer_private.pem \
    /usr/src/source/samplecode/helloworld/enclave/Enclave_private.pem
```

and proceed with the `buildPhase`:

```shell
[nix-shell:/usr/src/source]# buildPhase
```

### Audit Case: Comparing two signed enclaves
This section presents a simple approach that may be used for auditing
purposes. Given a signed enclave, an auditor wishes to reproduce the enclave
build, and verify its integrity. The approach is based on [Intel's
AE Reproducibility Verification](https://github.com/intel/linux-sgx/tree/master/linux/reproducibility/ae_reproducibility_verifier).

After having built and signed the enclave as shown above, one can use
Intel's script `reproducibility_verifier.sh` to verify the reproducibility
of a signed enclave, using a different private key to sign the "reproducible"
enclave build.

Make sure you are in `helloworld` directory:

```shell
cd /usr/src/source/samplecode/helloworld
```

Run Intel's script, passing the auditor's private key:

```shell
/usr/src/reproducibility_verifier.sh \
    bin/enclave.signed.so enclave/enclave.so \
    /usr/src/keys/Auditor_private.pem \
    enclave/Enclave.config.xml
* developer signed AE is:       bin/enclave.signed.so
* auditor unsigned AE is:       enclave/enclave.so
* auditor private key is:       /usr/src/keys/Auditor_private.pem
* developer config.xml is:      enclave/Enclave.config.xml
Reproducibility Verification PASSED!
```

See the section below for more details, on how the check works.

#### Audit Case: More detailed presentation
This section is self-contained, and therefore repeats some of the above
material.

First build the image:

```shell
$ docker-compose build nix-rust-sgx-sdk
```

Launch a container:

```shell
$ docker-compose run --rm nix-rust-sgx-sdk
```

Once in the container, start a `nix-shell` session:

```shell
bash-4.4# nix-shell rust-sgx-sdk.nix
```

Unpack the Rust SGX SDK source code:

```shell
[nix-shell:/usr/src]# unpackPhase
unpacking source archive /nix/store/msvp3cfv2d8h0r9dhb2mqypkhil0nzra-source
source root is source
```

Go into the directory where the application sample application is, and
build the enclave:

```shell
[nix-shell:/usr/src]# cd source/samplecode/helloworld/
[nix-shell:/usr/src/source]# make enclave/enclave.so
```

Sign the enclave with the "developer" key:

```shell
$sgxsdk/sgxsdk/bin/x64/sgx_sign sign \
    -key /usr/src/keys/Developer_private.pem \
    -enclave enclave/enclave.so \
    -out bin/dev.enclave.signed.so \
    -config enclave/Enclave.config.xml
```

Sign the enclave with the auditor key:

```shell
$sgxsdk/sgxsdk/bin/x64/sgx_sign sign \
    -key /usr/src/keys/Auditor_private.pem \
    -enclave enclave/enclave.so \
    -out bin/audit.enclave.signed.so \
    -config enclave/Enclave.config.xml
```

Compare the metadata of the signed enclaves, using Intel's suggested approach,
in https://github.com/intel/linux-sgx/tree/master/linux/reproducibility/ae_reproducibility_verifier#2-verify-by-manual.

Dump and extract the metadata of each enclave, and compare the extracted
metadata.

**Extract the metadata of the developer's signed enclave**:

```shell
# dump metadata
${SGX_SDK}/bin/x64/sgx_sign dump -enclave bin/dev.enclave.signed.so -dumpfile dev_metadata_orig.txt

# extract metadata
sed -n '/metadata->magic_num/,/metadata->enclave_css.header.module_vendor/p;/metadata->enclave_css.header.header2/,/metadata->enclave_css.header.hw_version/p;/metadata->enclave_css.body.misc_select/,/metadata->enclave_css.body.isv_svn/p;' dev_metadata_orig.txt > dev_metadata.txt
```

**Extract the metadata of the enclave signed by the auditor**:

```shell
# dump metadata
${SGX_SDK}/bin/x64/sgx_sign dump -enclave bin/audit.enclave.signed.so -dumpfile audit_metadata_orig.txt

# extract metadata
sed -n '/metadata->magic_num/,/metadata->enclave_css.header.module_vendor/p;/metadata->enclave_css.header.header2/,/metadata->enclave_css.header.hw_version/p;/metadata->enclave_css.body.misc_select/,/metadata->enclave_css.body.isv_svn/p;' audit_metadata_orig.txt > audit_metadata.txt
```

**Compare the two metadata files**:

```shell
diff dev_metadata.txt audit_metadata.txt
```
