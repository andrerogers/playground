# playground
Vagrant configuration for dev environment

Usage
-----

### VirtualBox Provider

Install [Packer](https://www.packer.io/downloads), [VirtualBox](https://www.virtualbox.org/), and [Vagrant](https://www.vagrantup.com/downloads)
should be good to clone this repo and go:

    $ cd playground/
    $ packer build -only=virtualbox-iso arch-template.json

Then import the generated box into Vagrant:

    $ vagrant box add arch output/packer_arch_virtualbox.box
