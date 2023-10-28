output "BH_public_IP" {
  value = openstack_networking_floatingip_v2.bastion_fip.address
}

output "BH_private_IP" {
  value = openstack_compute_instance_v2.bastion_instance.access_ip_v4
}

output "minikube_instance_IP" {
  value = openstack_compute_instance_v2.minikube_instance.access_ip_v4
}
