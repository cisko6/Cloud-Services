
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

# module "network" {
#   source = "./modules/network"
# }

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

resource "openstack_compute_keypair_v2" "test_pcBeast" {
  count      = var.create_key ? 1 : 0
  name       = var.key_name
  public_key = tls_private_key.rsa[count.index].public_key_openssh
}

resource "tls_private_key" "rsa" {
  count     = var.create_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rsa_private_key" {
  count    = var.create_key ? 1 : 0
  content  = tls_private_key.rsa[count.index].private_key_openssh
  filename = var.key_name
}

###

data "template_file" "bastion_data" {
  depends_on = [openstack_compute_instance_v2.private_instance]
  template   = file("user_data_script.sh")
  vars = {
    IP_addr = openstack_compute_instance_v2.private_instance.access_ip_v4
  }
}


resource "openstack_compute_instance_v2" "bastion_instance" {
  name            = var.instance_settings[1].name
  image_name      = var.instance_settings[1].image_name
  flavor_name     = var.instance_settings[1].flavor_name
  key_pair        = var.key_name
  security_groups = ["default"]
  user_data       = data.template_file.bastion_data.rendered
  depends_on      = [data.template_file.bastion_data]

  network {
    port = openstack_networking_port_v2.bastion_priv_port.id
  }
}

resource "openstack_compute_instance_v2" "private_instance" {
  name            = var.instance_settings[0].name
  image_name      = var.instance_settings[0].image_name
  flavor_name     = var.instance_settings[0].flavor_name
  key_pair        = var.key_name
  security_groups = ["default"]

  network {
    port = openstack_networking_port_v2.private_port.id
  }
}


# resource "openstack_compute_instance_v2" "multiple_instances" {
#   count = 2
#   name            = var.instance_settings[count.index].name
#   image_name      = var.instance_settings[count.index].image_name
#   flavor_name     = var.instance_settings[count.index].flavor_name
#   key_pair        = var.key_name
#   security_groups = ["default"]
#   #depends_on = count.index == 1 ? [data.template_file.bastion_data] : []
#   #user_data = count.index == 1 ? data.template_file.bastion_data.rendered : null
#   #user_data = count.index == 1 ? file("user_data_script.sh") : null
#   TOTO VYSKUSAT -> user_data = count.index == 0 ? templatefile("${path.module}/user_data/your-user-data-script.sh", {}) : null


#   network {
#     port = count.index == 1 ? openstack_networking_port_v2.bastion_priv_port.id : openstack_networking_port_v2.private_port.id
#   }
# }
