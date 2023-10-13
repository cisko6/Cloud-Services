
resource "openstack_networking_network_v2" "bastion_network" {
  name           = "bastion_network"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "private_network" {
  name           = "private_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "bastion_subnet" {
  name       = "bastion_subnet"
  network_id = openstack_networking_network_v2.bastion_network.id
  cidr       = "192.168.4.0/24"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private_subnet"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = "192.168.10.0/24"
  ip_version = 4
}
##########################################################################################
resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  admin_state_up      = true
  external_network_id = "3b3d6331-6050-497b-826f-4144382160bd"
  #enable_snat
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.bastion_subnet.id
}

resource "openstack_networking_router_interface_v2" "router_interface_2" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}
##########################################################################################
resource "openstack_networking_port_v2" "bastion_priv_port" {
  name           = "bastion_priv_port"
  network_id     = openstack_networking_network_v2.bastion_network.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.bastion_subnet.id
  }
}

resource "openstack_networking_port_v2" "private_port" {
  name           = "private_port"
  network_id     = openstack_networking_network_v2.private_network.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private_subnet.id
  }
}
##########################################################################################
resource "openstack_networking_floatingip_v2" "public_floating_ip" {
  pool = "ext-net-154"
}

resource "openstack_compute_floatingip_associate_v2" "public_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.public_floating_ip.address
  instance_id = openstack_compute_instance_v2.bastion_instance.id
}
##########################################################################################

resource "openstack_compute_instance_v2" "bastion_instance" {
  name            = "bastion_instance"
  image_name      = "ubuntu-22.04-KIS"
  flavor_name     = "1c05r8d"
  key_pair        = var.key_name
  security_groups = ["default"]

  network {
    port = openstack_networking_port_v2.bastion_priv_port.id
  }
}

resource "openstack_compute_instance_v2" "private_instance" {
  name            = "private_instance"
  image_name      = "ubuntu-22.04-KIS"
  flavor_name     = "1c05r8d"
  key_pair        = var.key_name
  security_groups = ["default"]

  network {
    port = openstack_networking_port_v2.private_port.id
  }
}
