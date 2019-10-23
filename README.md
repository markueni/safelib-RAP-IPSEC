# sgx-secrets-over-s2s-strongswan

This repo is based on [rgl/strongswan-site-to-site-vpn-vagrant](https://github.com/rgl/strongswan-site-to-site-vpn-vagrant). See original `README.md` in `README.old.md`

## Description

This project sets up site-to-site VPN using 4 VMs. Each site contains a gateway and a host:

    sun-ubuntu --- sun <=> moon --- moon-ubuntu

`sun` and `moon` are gateways, and `sun-ubuntu`, `moon-ubuntu` are their respective hosts.

We set up SSH tunnel to forward traffic from `client` running on host OS to `server`.

    sun-ubuntu --- sun <= VPN => moon --- moon-ubuntu <= SSH tunnel => host OS
    server ----------- <= VPN => -------------------- <= SSH tunnel => client

## Prerequisites

Install [Virtualbox](https://www.virtualbox.org)

Install [Vagrant](https://www.vagrantup.com/intro/getting-started/index.html)

Prepare `settings` and `AttestationReportSigningCACert.pem` files and place them into `./sgx-secrets-after-ra`.

## Usage

This paragraph shows basic usage based on simple HTTP server. It demonstrates that the VPN is actually encrypting the traffic.

Fetch submodules

    git submodule update --init

Start everything

    vagrant up # takes a lot of time

Login into the moon machine (a VPN device), and watch the network traffic:

    vagrant ssh moon-ubuntu
    # then, inside the VM:
    tcpdump -n -i any tcp port 3000

From your host computer, access the following URLs to see them working:

    http://10.1.0.4:3000
    http://10.2.0.4:3000

Then, see how site-to-site traffic looks like:

    vagrant ssh moon-ubuntu
    # then, inside the VM:
    wget -qO- 10.2.0.4:3000

## Running `sgx-secrets-after-ra`

When running the example, you have to setup SSH tunnel to `moon-ubuntu`

    vagrant ssh moon-ubuntu -- -L 7777:10.2.0.4:7777
    sudo tcpdump -n -i any tcp port 7777 # show traffic

Now any traffic pointed to `localhost:7777` on host OS will be forwarded to `sun-ubuntu`, i.e. `server` application that provides secrets.

SSH into `sun-ubuntu` host to set up the `server`

    vagrant ssh sun-ubuntu
    cd /vagrant/sgx-secrets-after-ra
    ./bootstrap
    ./configure
    make
    ./run-server

Now run `client` on host OS as usual:

    cd /path/to/this/project/sgx-secrets-after-ra
    ./bootstrap
    ./configure
    make
    ./run-client

## Running on Windows

Install `rsync` to use `synced_folder`:

    choco install rsync

If you don't have `rsync` installed, you can disable `sync_folder` in `Vagrantfile` by setting `disabled: false` to `disabled: true`:

    config.vm.synced_folder ".", "/vagrant/", type: "rsync", disabled: false,

Now checkout from git manually:

    mkdir -p ~/project
    cd project
    

Keep in mind that local changes _won't_ be propagated from host OS to VM.
