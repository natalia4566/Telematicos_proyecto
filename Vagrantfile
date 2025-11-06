# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"   # Ubuntu 22.04 LTS

  # Configuración general para todas las máquinas
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  # 1️⃣ MySQL Primario
  config.vm.define "db-primary" do |node|
    node.vm.hostname = "db-primary"
    node.vm.network "private_network", ip: "192.168.56.10"
  end

  # 2️⃣ MySQL Réplica 1
  config.vm.define "db-replica1" do |node|
    node.vm.hostname = "db-replica1"
    node.vm.network "private_network", ip: "192.168.56.11"
  end

  # 3️⃣ MySQL Réplica 2
  config.vm.define "db-replica2" do |node|
    node.vm.hostname = "db-replica2"
    node.vm.network "private_network", ip: "192.168.56.12"
  end

  # 4️⃣ Nginx Load Balancer
  config.vm.define "lb-nginx" do |node|
    node.vm.hostname = "lb-nginx"
    node.vm.network "private_network", ip: "192.168.56.20"
  end
end