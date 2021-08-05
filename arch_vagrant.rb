# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile - One development machine to rule them all.

Vagrant.configure(2) do |config|
  config.vm.box_check_update = true

  config.vm.provider :virtualbox do |v, override|
    v.customize ["modifyvm", :id, "--memory", 2048]
    v.customize ["modifyvm", :id, "--cpus", 2]
    v.gui = true 
  end

end