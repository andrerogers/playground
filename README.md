# playground
Vagrant configuration for dev environment

Usage
-----

### VirtualBox Provider

Install Packer, [VirtualBox](https://www.virtualbox.org/), and Vagrant
should be good to clone this repo and go:

    $ git clone https://github.com/elasticdog/packer-arch.git
    $ cd packer-arch/
    $ packer build -only=virtualbox-iso arch-template.json

Then import the generated box into Vagrant:

    $ vagrant box add arch output/packer_arch_virtualbox.box
