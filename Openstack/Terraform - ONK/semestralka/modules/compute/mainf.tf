terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

resource "openstack_compute_floatingip_associate_v2" "bastion_fip_association" {
  floating_ip = var.bastion_fip.address
  instance_id = openstack_compute_instance_v2.bastion_instance.id
}

###

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

#######################################################################################

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
    port = var.bastion_priv_port.id
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
    port = var.minikube_priv_port_id
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