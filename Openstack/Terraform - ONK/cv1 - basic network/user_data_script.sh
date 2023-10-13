#! /bin/bash

private_IP_addr="${IP_addr}"

# POVOLIT IP FORWARDING
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# ENABLE TRAFFIC THROUGH BASTION HOST
sudo iptables -t nat -A PREROUTING -p tcp -i ens3 --dport 22 -j DNAT --to-destination $private_IP_addr:22
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

#iptables -t nat -L -n -v
