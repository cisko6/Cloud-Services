
locals {
  kis_os_region = "RegionOne"
  auth_url      = "https://158.193.152.44:5000/v3/"

  kis_os_endpoint_overrides = {
    network = "https://158.193.152.44:9696/v2.0/"
  }
  domain_name   = "admin_domain"
}

