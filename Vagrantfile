# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile - One development machine to rule them all.

Vagrant.configure("2") do |config|
  config.vm.box = "playground"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.name = "playground"
    vb.linked_clone = true
    vb.check_guest_additions = true
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  #config.vm.provision "shell" do |s|
  #  ssh_priv_key = File.readlines(".\\ssh\\id_rsa").first.strip
  #  ssh_pub_key = File.readlines(".\\ssh\\id_rsa.pub").first.strip
  #  s.inline = <<-SHELL
  #    echo #{ssh_priv_key} > /home/senor-dre/.ssh/git
  #    echo #{ssh_pub_key} > /home/senor-dre/.ssh/git.pub
  #    echo #{ssh_pub_key} >> /home/senor-dre/.ssh/authorized_keys
  #  SHELL
  #end

  config.ssh.private_key_path = ".\\ssh\\id_rsa"
  config.ssh.forward_agent = true

  config.vm.provision "file", source: ".\\ssh\\.", destination: "/home/vagrant/.ssh"
  config.vm.provision "shell", path: "bootstrap.sh"

  # Setting up for multi-machine
  # config.define "base" do |base|
  #   base.vm.provision
  # end

  # trigger reload
  # config.vm.provision :reload
end
