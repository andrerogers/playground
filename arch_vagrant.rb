# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile - One development machine to rule them all.

Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 1800
#   config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.box_check_update = true

  # config.vm.post_up_message = ""
  config.vm.boot_timeout = 1800
  # config.vm.box_download_checksum = true
  config.vm.boot_timeout = 1800

  config.vm.provider :virtualbox do |v, override|
    v.customize ["modifyvm", :id, "--memory", 2048]
    v.customize ["modifyvm", :id, "--vram", 256]
    v.customize ["modifyvm", :id, "--cpus", 2]
    v.gui = true 
  end

end