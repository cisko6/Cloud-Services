
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

# module "network" {
#   source = "./modules/network"
# }

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

resource "openstack_compute_floatingip_associate_v2" "bastion_fip_association" {
  floating_ip = openstack_networking_floatingip_v2.bastion_fip.address
  instance_id = openstack_compute_instance_v2.bastion_instance.id
}
##########################################################################################
## KEY PAIR ##
resource "openstack_compute_keypair_v2" "keypair" {
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

## SCRIPT FILES ##

data "template_file" "bastion_data" {
  depends_on = [openstack_compute_instance_v2.minikube_instance]
  template   = file(var.bastion_userdata)
  vars = {
    IP_addr = openstack_compute_instance_v2.minikube_instance.access_ip_v4
  }
}

data "template_file" "minikube_data" {
  template = file(var.minikube_userdata)
  vars = {
    minikube_name = var.instance_settings[0].name
  }
}




## NULL RESOURCES ##

resource "null_resource" "wait_for_bastion" {
  depends_on = [openstack_compute_floatingip_associate_v2.bastion_fip_association]

  # treba počkať aby sa bootla inštancia
  provisioner "local-exec" {
    command = "ping 127.0.0.1 -n 16 > nul"
  }

  connection {
    type        = "ssh"
    host        = openstack_networking_floatingip_v2.bastion_fip.address
    user        = "ubuntu"
    private_key = file("${var.key_name}.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "until [ -f /tmp/user_data_bastion_complete ]; do sleep 5; done",
    ]
  }
}

resource "null_resource" "wait_for_minikube" {
  depends_on = [ null_resource.wait_for_bastion ]

  # treba počkať aby bolo SSH pripojenie na minikube a nie na bastion
  provisioner "local-exec" {
    command = "ping 127.0.0.1 -n 6 > nul"
  }

  connection {
    type        = "ssh"
    host        = openstack_networking_floatingip_v2.bastion_fip.address
    user        = "ubuntu"
    private_key = file("${var.key_name}.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "until [ -f /tmp/user_data_minikube_complete ]; do sleep 5; done",
    ]
  }
}

## INSTANCES ##

resource "openstack_compute_instance_v2" "bastion_instance" {
  depends_on = [ openstack_compute_instance_v2.minikube_instance, data.template_file.bastion_data]
  name            = var.instance_settings[1].name
  image_name      = var.instance_settings[1].image_name
  flavor_name     = var.instance_settings[1].flavor_name
  key_pair        = var.key_name
  security_groups = ["default"]
  user_data       = data.template_file.bastion_data.rendered

  network {
    port = openstack_networking_port_v2.bastion_priv_port.id
  }
}

resource "openstack_compute_instance_v2" "minikube_instance" {
  depends_on = [ data.template_file.minikube_data ]
  name            = var.instance_settings[0].name
  image_name      = var.instance_settings[0].image_name
  flavor_name     = var.instance_settings[0].flavor_name
  key_pair        = var.key_name
  security_groups = ["default"]

  user_data       = data.template_file.minikube_data.rendered

  network {
    port = openstack_networking_port_v2.minikube_priv_port.id
  }
}


# resource "openstack_compute_instance_v2" "multiple_instances" { # problem s dependecy -> bastion čaká na minikube (kvôli IP)
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
#     port = count.index == 1 ? openstack_networking_port_v2.bastion_priv_port.id : openstack_networking_port_v2.minikube_priv_port.id
#   }
# }
