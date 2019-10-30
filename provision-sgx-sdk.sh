#!/bin/bash
# Ref https://download.01.org/intel-sgx/sgx-linux/2.7/docs/Intel_SGX_Installation_Guide_Linux_2.7_Open_Source.pdf
sudo mkdir -p /usr/src/sdk
cp -r /vagrant/sgx-files/* /usr/src/sdk
sudo chown -R vagrant /usr/src/sdk
cd /usr/src/sdk

sudo apt-get -y install libssl-dev libcurl4-openssl-dev libprotobuf-dev
sudo apt-get -y install build-essential python

chmod 770 sgx_linux_x64_driver_2.6.0_4f5bb63.bin
sudo ./sgx_linux_x64_driver_2.6.0_4f5bb63.bin 
sudo dpkg -i ./libsgx-enclave-common_2.7.100.4-bionic1_amd64.deb
sudo dpkg -i ./libsgx-enclave-common-dev_2.7.100.4-bionic1_amd64.deb
sudo dpkg -i ./libsgx-enclave-common-dbgsym_2.7.100.4-bionic1_amd64.ddeb
echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/intelsgx.list

wget -qO- https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | sudo apt-key add -
sudo apt-get -y update
sudo apt-get -y install libsgx-enclave-common
sudo apt-get -y install libsgx-enclave-common-dbgsym

# echo 'yes' | ./sgx_linux_x64_sdk_2.7.100.4.bin
chmod 770 sgx_linux_x64_sdk_2.7.100.4.bin
./sgx_linux_x64_sdk_2.7.100.4.bin --prefix=/opt/intel

# Libiraries for compiling sgx sever code!
sudo apt-get -y install autotools-dev
sudo apt-get -y install automake
