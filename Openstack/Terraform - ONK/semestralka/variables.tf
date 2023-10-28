variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "tenant_name" {
  type = string
}

variable "auth_url" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_settings" {}

variable "create_key" {
  type = bool
}

variable "bastion_userdata" {
  type = string
}

variable "minikube_userdata" {
  type = string
}

# variable "CIDR" {
#   type = string
# }