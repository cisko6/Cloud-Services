#!/bin/bash
nameserver="nameserver 8.8.8.8"
private_IP_addr="${IP_addr}"

# PRIDANIE DNS SERVERA
#sudo echo "$nameserver" >> /etc/resolv.conf
echo "$nameserver" | sudo tee -a /etc/resolv.conf

sudo apt update

# POVOLIT IP FORWARDING
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p


# SIGNAL ZE UZ SKONCIL SCRIPT - preto skorej lebo by sa odtrhlo SSH spojenie
touch /tmp/user_data_bastion_complete

# aby stihol nullresource zaregovat na touch
sleep 5

# ENABLE SSH TRAFFIC THROUGH BASTION HOST
sudo iptables -t nat -A PREROUTING -p tcp -i ens3 --dport 22 -j DNAT --to-destination $private_IP_addr:22
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
