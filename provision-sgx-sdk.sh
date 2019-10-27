#!/bin/bash
set -eux

sudo mkdir -p /usr/src/sdk
cp -r /vagrant/sgx-files /usr/src/sdk/sgx-files
sudo chown -R vagrant /usr/src/sdk
cd /usr/src/sdk

sudo apt-get update && apt-get install -yq --no-install-recommends ca-certificates build-essential ocaml ocamlbuild automake autoconf \
    libtool wget python libssl-dev libssl-dev libcurl4-openssl-dev protobuf-compiler git libprotobuf-dev alien cmake debhelper uuid-dev \
    libxml2-dev xxd cpuid libelf-dev

git clone https://github.com/01org/dynamic-application-loader-host-interface.git &&
    cd dynamic-application-loader-host-interface &&
    cmake . -DCMAKE_BUILD_TYPE=Release -DINIT_SYSTEM=SysVinit &&
    make &&
    make install &&
    cd .. && rm -rf dynamic-application-loader-host-interface

cd /usr/src/sdk
cp sgx-files/install-psw.patch ./

git clone -b sgx_2.6 --depth 1 https://github.com/intel/linux-sgx &&
    cd linux-sgx &&
    patch -p1 -i ../install-psw.patch &&
    ./download_prebuilt.sh 2>/dev/null &&
    make -s -j$(nproc) sdk_install_pkg psw_install_pkg &&
    ./linux/installer/bin/sgx_linux_x64_sdk_*.bin --prefix=/opt/intel &&
    ./linux/installer/bin/sgx_linux_x64_psw_*.bin &&
    cd .. && rm -rf linux-sgx/

cd /usr/src/sdk
sudo cp sgx-files/jhi.conf /etc/jhi/jhi.conf

./sgx-files/entrypoint.sh
