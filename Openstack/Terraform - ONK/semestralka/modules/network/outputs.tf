
# WHOLE RESOURCES

output "minikube_priv_port_id" {
  value = openstack_networking_port_v2.minikube_priv_port.id
}

output "bastion_priv_port" {
  value = openstack_networking_port_v2.bastion_priv_port
}

# XXXXXXXXX
output "BH_public_IP" {
  value = openstack_networking_floatingip_v2.bastion_fip.address
}

output "bastion_fip" {
  value = openstack_networking_floatingip_v2.bastion_fip
}
