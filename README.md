# Lab
Automating an malware/attack lab

## Creating the Vagrant box from my own pfsense virtualbox vm
```
# Get a list of vms.
vboxmanage list vms

# Create the vagrant box with vm name from above.
vagrant package --base "EchoNet-pfSense" --output pfsense.box
```

## Connections
- pfSense is to have initial rules on the wan interface to allow access from your local lan
- WAN           - 192.168.2.0/24 (bridged adapter to your local network)
- LAN           - 10.10.100.1/24 (DHCP Range 10.10.100.10 - 10.10.100.100)
- AD            - 10.10.20.0/24
- Vulnerable    - 10.10.30.0/24
- Malware       - 10.10.40.0/24

## PFSENSE
- SSH is disabled by default
- If pfSense isn't available at the DHCP address, go to the vbox hypervisor and show the new vm. Enter a shell with the 8 option. Run this to temproarily disable all rules ```pfctl -d```
- Admin panel will be available from the DHCP address picked up from your local lan
- Admin creds admin:pfsense
- Vagrant user is created with sudo privileges and password authentication



```
vagrant plugin install vagrant-none-communicator

# Use the none communicator. Vagrant will not be able to 
  # communicate with the guest
  config.vm.communicator = "none"
```