# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  # MySQL Primario
  config.vm.define "db-primary" do |node|
    node.vm.hostname = "db-primary"
    node.vm.network "private_network", ip: "192.168.56.10"
    node.vm.provision "shell", path: "scripts/setup-master.sh"
  end

  # Réplica 1
  config.vm.define "db-replica1" do |node|
    node.vm.hostname = "db-replica1"
    node.vm.network "private_network", ip: "192.168.56.11"
    node.vm.provision "shell", path: "scripts/setup-replica.sh", args: ["192.168.56.10"]
  end

  # Réplica 2
  config.vm.define "db-replica2" do |node|
    node.vm.hostname = "db-replica2"
    node.vm.network "private_network", ip: "192.168.56.12"
    node.vm.provision "shell", path: "scripts/setup-replica.sh", args: ["192.168.56.10"]
  end

  # Nginx Load Balancer
  config.vm.define "lb-nginx" do |node|
    node.vm.hostname = "lb-nginx"
    node.vm.network "private_network", ip: "192.168.56.20"
    node.vm.provision "shell", path: "scripts/setup-nginx.sh"
  end
end
