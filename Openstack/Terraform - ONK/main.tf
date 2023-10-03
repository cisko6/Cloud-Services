
resource "openstack_networking_network_v2" "main" {
  name           = var.username
  admin_state_up = "true"
}

