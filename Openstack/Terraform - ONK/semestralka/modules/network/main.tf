terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

resource "openstack_networking_network_v2" "bastion_network" {
  name           = "bastion_network"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "minikube_network" {
  name           = "minikube_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "bastion_subnet" {
  name       = "bastion_subnet"
  network_id = openstack_networking_network_v2.bastion_network.id
  cidr       = "192.168.4.0/24"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "minikube_subnet" {
  name       = "minikube_subnet"
  network_id = openstack_networking_network_v2.minikube_network.id
  cidr       = "192.168.10.0/24"
  ip_version = 4
}

# ##########################################################################################
resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  admin_state_up      = true
  external_network_id = "3b3d6331-6050-497b-826f-4144382160bd"
  #enable_snat = true
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.bastion_subnet.id
}

resource "openstack_networking_router_interface_v2" "router_interface_2" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.minikube_subnet.id
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

resource "openstack_networking_port_v2" "minikube_priv_port" {
  name           = "minikube_priv_port"
  network_id     = openstack_networking_network_v2.minikube_network.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.minikube_subnet.id
  }
}

##########################################################################################
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  pool = "ext-net-154"
}
