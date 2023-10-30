
# resource "openstack_networking_network_v2" "network_1" {
#   name           = "network_1"
#   admin_state_up = "true"
# }

# resource "openstack_networking_subnet_v2" "subnet_1" {
#   name       = "subnet_1"
#   network_id = openstack_networking_network_v2.network_1.id
#   cidr       = "192.168.199.0/24"
#   ip_version = 4
# }

# resource "openstack_networking_router_v2" "router_1" {
#   name                = "router_1"
#   admin_state_up      = true
#   external_network_id = "3b3d6331-6050-497b-826f-4144382160bd"
# }

# resource "openstack_networking_router_interface_v2" "router_interface_1" {
#   router_id = openstack_networking_router_v2.router_1.id
#   subnet_id = openstack_networking_subnet_v2.subnet_1.id
# }


module "network" {
  source = "./modules/networking"
}
output "xdd" {
  value = module.network.router_name
}

# resource "openstack_networking_floatingip_v2" "floatip_1" {
#   pool = "ext-net-154"
# }

# resource "openstack_compute_floatingip_associate_v2" "fip_1" {
#   floating_ip = openstack_networking_floatingip_v2.floatip_1.address
#   instance_id = openstack_compute_instance_v2.test123.id
# }

# resource "openstack_compute_instance_v2" "test123" {
#   name            = "test123"
#   image_name      = "ubuntu-22.04-kis"
#   flavor_name     = "2c2r20d"
#   key_pair        = "test_pcBeast"
#   security_groups = ["default"]

#   network {
#     name = module.network.network_1.name
#   }
# }
