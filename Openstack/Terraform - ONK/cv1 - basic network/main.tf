
resource "openstack_networking_network_v2" "main" {
  name           = var.username
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.main.id
  cidr       = "192.168.4.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router" {
  name                = "my_router"
  admin_state_up      = true
}

resource "openstack_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id     = "ext-net"
  admin_state_up = "true"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}
