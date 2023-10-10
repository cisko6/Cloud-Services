
resource "openstack_networking_network_v2" "main_network" {
  name           = var.username
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private_subnet"
  network_id = openstack_networking_network_v2.main_network.id
  cidr       = "192.168.4.0/24"
  ip_version = 4
}

resource "openstack_compute_instance_v2" "public_instance" {
  name            = "public_instance"
  image_name      = "ubuntu-22.04-KIS"
  flavor_name     = "1c05r8d"
  key_pair        = "test"
  security_groups = ["default"]

  network {
    name = "ext-net-154"
  }
}

resource "openstack_compute_instance_v2" "private_instance" {
  name            = "private_instance"
  image_name      = "ubuntu-22.04-KIS"
  flavor_name     = "1c05r8d"
  key_pair        = "test"
  security_groups = ["default"]

  network {
    name = openstack_networking_network_v2.main_network.name
  }
}
