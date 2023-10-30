terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      #version = "1.53.0"
    }
  }
}

provider "openstack" {
  user_name          = var.username
  tenant_name        = var.tenant_name
  password           = var.password
  auth_url           = var.auth_url
  region             = local.kis_os_region
  insecure           = true
  endpoint_overrides = local.kis_os_endpoint_overrides
  domain_name        = local.domain_name
}
