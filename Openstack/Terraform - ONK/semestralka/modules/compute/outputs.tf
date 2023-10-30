
# WHOLE RESOURCES

output "bastion_fip_association" {
  value = openstack_compute_floatingip_associate_v2.bastion_fip_association
}

# XXXXXXXXX

output "BH_private_IP" {
  value = openstack_compute_instance_v2.bastion_instance.access_ip_v4
}

output "minikube_instance_IP" {
  value = openstack_compute_instance_v2.minikube_instance.access_ip_v4
}
