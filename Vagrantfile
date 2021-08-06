# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile - One development machine to rule them all.

Vagrant.configure("2") do |config|
  config.ssh.username = "root"
  config.ssh.password = "packer" 

  config.vm.box = "playground"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = true 

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.name = "playground"
    vb.linked_clone = true
    vb.check_guest_additions = true
  end

  config.vm.provision "file" do |vb|
    vb.source = "./ssh/."
    vb.destination = "/root/.ssh"
  end

  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/00-init.sh"
    vb.env = {"USER" => "sensei-dre"}
  end

  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/01-yay.sh"
    vb.env = {"USER" => "sensei-dre"}
  end

  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/02-zsh.sh"
    vb.env = {"USER" => "sensei-dre"}
  end

  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/03-wm.sh"
    vb.env = {"USER" => "sensei-dre"}
  end

  # TODO
  # try executing the curl alone as none privvilleged after moving the ssh files
  # echo ">>>> bootstrap.sh: Hot-load zsh env.."
  # source /home/$USER/.zshrc


  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/04-env.sh"
    vb.env = {"USER" => "sensei-dre"}
  end

  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/05-emacs.sh"
    vb.env = {"USER" => "sensei-dre"}
  end

  config.vm.provision "shell" do |vb| 
    vb.path = "./bootstrap/fin.sh"
    vb.env = {"USER" => "sensei-dre"}
  end
end
