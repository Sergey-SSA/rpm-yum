# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "rpm2"
  config.vm.define "rpm2"

  config.vm.box_check_update = false

  config.vm.provision "shell", path: "provision.sh"
end
