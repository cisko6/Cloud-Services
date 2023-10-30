output "BH_public_IP" {
  #value = openstack_networking_floatingip_v2.bastion_fip.address
  value = module.network.BH_public_IP
}

output "BH_private_IP" {
  value = module.compute.BH_private_IP
}

output "minikube_instance_IP" {
  value = module.compute.minikube_instance_IP
}
