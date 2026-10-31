master_ip="192.168.56.10"
worker1_ip="192.168.56.11"
worker2_ip="192.168.56.12"


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Nodo master
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "#{master_ip}"

    master.vm.provider "virtualbox" do |vb|
      vb.name = "bigdata-master"
      vb.memory = 2048
      vb.cpus = 2
    end
  end

  # Worker 1
  config.vm.define "worker1" do |worker1|
    worker1.vm.hostname = "worker1"
    worker1.vm.network "private_network", ip: "#{worker1_ip}"

    worker1.vm.provider "virtualbox" do |vb|
      vb.name = "bigdata-worker1"
      vb.memory = 1536
      vb.cpus = 1
    end
  end

  # Worker 2
  config.vm.define "worker2" do |worker2|
    worker2.vm.hostname = "worker2"
    worker2.vm.network "private_network", ip: "#{worker2_ip}"

    worker2.vm.provider "virtualbox" do |vb|
      vb.name = "bigdata-worker2"
      vb.memory = 1536
      vb.cpus = 1
    end

    worker2.trigger.after :up do |trigger|
      trigger.name = "Aprovisionamiento automatico con Ansible"
      trigger.info = "Ejecutando el script de aprovisionamiento desde WSL..."

      trigger.run = {
        inline: "wsl.exe --cd \"#{File.expand_path(__dir__)}\" --exec bash scripts/provision-wsl.sh"
      }
    end
  end
end
