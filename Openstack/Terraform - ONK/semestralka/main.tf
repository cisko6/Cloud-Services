
module "network" {
  source = "./modules/network"
}

module "compute" {
  source = "./modules/compute"

  create_key = var.create_key
  key_name = var.key_name
  minikube_userdata = var.minikube_userdata
  bastion_userdata = var.bastion_userdata

  bastion_priv_port = module.network.bastion_priv_port
  minikube_priv_port_id = module.network.minikube_priv_port_id
  instance_settings = var.instance_settings
  bastion_fip = module.network.bastion_fip
}


resource "null_resource" "wait_for_bastion" {
  depends_on = [ module.compute.bastion_fip_association ]

  connection {
    type        = "ssh"
    host        = module.network.bastion_fip.address
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
    host        = module.network.bastion_fip.address
    user        = "ubuntu"
    private_key = file("${var.key_name}.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "until [ -f /tmp/user_data_minikube_complete ]; do sleep 5; done",
    ]
  }
}
