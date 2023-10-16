output "BH_public_IP" {
  value = openstack_networking_floatingip_v2.public_floating_ip.address
}

output "BH_private_IP" {
  value = openstack_compute_instance_v2.bastion_instance.access_ip_v4
}

output "private_instance_IP" {
  value = openstack_compute_instance_v2.private_instance.access_ip_v4
}
