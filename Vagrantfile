<<<<<<< HEAD
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
=======
# Weird hack to bypass some dhcp interface issues.
# Will be resolved by Vagrant someday.
class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end

Vagrant.configure("2") do |config|
  config.vm.define "pfsense" do |pfsense|
    # pfsense.vm.guest = :freebsd
    pfsense.vm.box = "EchoLab-pfSense.box"
    # Use the none communicator. Vagrant will not be able to 
    # communicate with the guest
    pfsense.vm.communicator = "none"
    
    pfsense.vm.hostname = "echolab-fw"
    
    # Interface 1: WAN (Bridged for Internet access)
    pfsense.vm.network "public_network", bridge: "enp0s31f6", auto_config: false

    # Interface 2: LAN (Host-only for management)
    # Static IPs here are meaningless, /cf/conf/config.xml will override.
    pfsense.vm.network "private_network", type: "static", ip: "192.168.56.2", virtualbox__intnet: "attack_lan"

    # # Interface 3: Optional Network 1 (Internal)
    pfsense.vm.network "private_network", type: "static", ip: "192.168.56.3", virtualbox__intnet: "lab_lan"

    # # Interface 4: Optional Network 2 (Internal)
    pfsense.vm.network "private_network", type: "static", ip: "192.168.56.4", virtualbox__intnet: "malware_lan"

    pfsense.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      # vb.name = "EchoLab-pfSense"

      # Force disable NAT and set Adapter 1 as Bridged
      vb.customize ["modifyvm", :id, "--nic1", "bridged"]
      vb.customize ["modifyvm", :id, "--bridgeadapter1", "enp0s31f6"] # Change "eth0" to your actual network interface

      # Ensure internal network for other adapters
      vb.customize ["modifyvm", :id, "--nic2", "intnet"]
      vb.customize ["modifyvm", :id, "--nic3", "intnet"]
      vb.customize ["modifyvm", :id, "--nic4", "intnet"]
    end
  end

  # Kali Linux VM Configuration
  config.vm.define "kali" do |kali|
    kali.vm.box = "kalilinux/rolling" # Use the official Kali Linux box

    # Disable default Vagrant SSH communication (optional)
    # kali.vm.communicator = "none"
    # kali.ssh.host = "10.10.10.12"

    # Disable NAT
    kali.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      # vb.customize ["modifyvm", :id, "--nic1", "intnet"]  # Disable NAT, connect Kali to internal network
    end
    kali.vm.network "private_network", type: "dhcp", virtualbox__intnet: "echonet-LAN" # Attach Kali to pfSense's attack_lan (single interface)
  
    # Run Ansible provisioner
    kali.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "./provision/attack/kali.yml"
    end

    # kali.vm.provision "shell", run: "always", privileged: true, inline: <<-SHELL
    #   echo "Disabling NAT interface (Adapter 1)..."
    #   VBoxManage modifyvm kali --nic1 none
    # SHELL
  end

  # Windows Server Domain Controller
  config.vm.define "dc" do |dc|
    dc.vm.box = "gusztavvargadr/windows-server-2022" # Use a Windows Server 2022 box

    # Disable default Vagrant SSH communication (optional)
    # kali.vm.communicator = "none"

    dc.vm.hostname = "lab-dc"
    dc.vm.network "private_network", type: "dhcp", ip: "192.168.56.10", virtualbox__intnet: "lab_lan"

    dc.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = 2
    end

    # Auto-install Active Directory Domain Services (AD DS)
    dc.vm.provision "shell", inline: <<-SHELL
      Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
      Install-WindowsFeature -Name DNS -IncludeManagementTools
      Install-WindowsFeature -Name DHCP -IncludeManagementTools
      Install-WindowsFeature -Name RSAT-AD-AdminCenter -IncludeManagementTools
      Write-Host "Active Directory and DNS installed. Reboot required!"
    SHELL
  end
end


>>>>>>> dc25729 (Vagrantfile and initial provisioning ansible.)
