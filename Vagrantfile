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
