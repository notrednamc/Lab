Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 2
  end

  # pfSense Firewall (Handles all segmentation)
  config.vm.define "pfsense" do |pfsense|
    pfsense.vm.box = "generic/freebsd13"

    # WAN (Bridged to host network for internet access)
    pfsense.vm.network "public_network", bridge: "eth0", use_dhcp_assigned_default_route: true

    # Internal Networks
    pfsense.vm.network "private_network", ip: "10.10.10.1", virtualbox__intnet: "net_attack"
    pfsense.vm.network "private_network", ip: "10.10.20.1", virtualbox__intnet: "net_ad"
    pfsense.vm.network "private_network", ip: "10.10.30.1", virtualbox__intnet: "net_vuln"
    pfsense.vm.network "private_network", ip: "10.10.40.1", virtualbox__intnet: "net_malware"

    pfsense.vm.provision "shell", inline: <<-SHELL
      echo "pfSense initial configuration"

      # Enable IP forwarding
      sysctl net.inet.ip.forwarding=1

      # NAT configuration (Attack network can access the internet)
      pfctl -F all
      echo "nat on vtnet0 from 10.10.10.0/24 to any -> (vtnet0)" | pfctl -f -

      # Firewall rules:
      # - Allow Attack network full access
      # - Block inter-network traffic for all others
      echo "
        block in all
        pass in on vtnet1 from 10.10.10.0/24 to any
        pass out on vtnet0 from 10.10.10.0/24 to any
      " | pfctl -f -

    SHELL
  end

  # Attack/Management Network (Allowed to reach other networks + Internet)
  config.vm.define "kali" do |kali|
    kali.vm.box = "kalilinux/rolling"
    kali.vm.network "private_network", ip: "10.10.10.10", virtualbox__intnet: "net_attack"
    kali.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/attack/kali.yml"
    end
  end

  config.vm.define "commando" do |commando|
    commando.vm.box = "gusztavvargadr/windows-10"
    commando.vm.network "private_network", ip: "10.10.10.20", virtualbox__intnet: "net_attack"
    commando.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/attack/commando.yml"
    end
  end

  # AD Domain Network (10.10.20.0/24) - Isolated except to Attack
  config.vm.define "dc" do |dc|
    dc.vm.box = "gusztavvargadr/windows-server"
    dc.vm.network "private_network", ip: "10.10.20.10", virtualbox__intnet: "net_ad"
    dc.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/domain/domain_controller.yml"
    end
  end

  config.vm.define "workstation1" do |ws1|
    ws1.vm.box = "gusztavvargadr/windows-10"
    ws1.vm.network "private_network", ip: "10.10.20.11", virtualbox__intnet: "net_ad"
    ws1.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/domain/wkstn1.yml"
    end
  end

  config.vm.define "workstation2" do |ws2|
    ws2.vm.box = "gusztavvargadr/windows-10"
    ws2.vm.network "private_network", ip: "10.10.20.12", virtualbox__intnet: "net_ad"
    ws2.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/domain/wkstn2.yml"
    end
  end

  # Vulnerable Lab (10.10.30.0/24) - Isolated except to Attack
  config.vm.define "metasploitable" do |meta|
    meta.vm.box = "rapid7/metasploitable3"
    meta.vm.network "private_network", ip: "10.10.30.10", virtualbox__intnet: "net_vuln"
  end

  config.vm.define "juiceshop" do |js|
    js.vm.box = "bento/ubuntu-20.04"
    js.vm.network "private_network", ip: "10.10.30.11", virtualbox__intnet: "net_vuln"
    js.vm.provision "shell", inline: "docker run -d -p 3000:3000 bkimminich/juice-shop"
  end

  # Malware Lab (10.10.40.0/24) - Isolated except to Attack
  config.vm.define "malware_win10" do |mw10|
    mw10.vm.box = "gusztavvargadr/windows-10"
    mw10.vm.network "private_network", ip: "10.10.40.10", virtualbox__intnet: "net_malware"
    mw10.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/malware/malware_lab.yml"
    end
  end

  config.vm.define "malware_win11" do |mw11|
    mw11.vm.box = "gusztavvargadr/windows-11"
    mw11.vm.network "private_network", ip: "10.10.40.11", virtualbox__intnet: "net_malware"
    mw11.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/malware/malware_lab.yml"
    end
  end

  config.vm.define "malware_server" do |mws|
    mws.vm.box = "gusztavvargadr/windows-server"
    mws.vm.network "private_network", ip: "10.10.40.12", virtualbox__intnet: "net_malware"
    mws.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision/malware/malware_lab.yml"
    end
  end

  # Define RDP Access for each VM
  rdp_ports = {
    "kali" => 3390,
    "commando" => 3391,
    "dc" => 3392,
    "workstation1" => 3393,
    "workstation2" => 3394,
    "malware_win10" => 3395,
    "malware_win11" => 3396,
    "malware_server" => 3397
  }

  rdp_ports.each do |vm_name, host_port|
    config.vm.define vm_name do |machine|
      machine.vm.network "forwarded_port", guest: 3389, host: host_port, auto_correct: true
    end
  end
end
