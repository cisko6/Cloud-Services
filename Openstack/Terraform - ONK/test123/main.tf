

resource "openstack_compute_instance_v2" "test123" {
  name            = "test123"
  image_name      = "ubuntu-22.04-kis"
  flavor_name     = "2c2r20d"
  key_pair        = "test-ntbk"
  security_groups = ["default"]

  network {
    name = "ext-net-154"
  }
}
