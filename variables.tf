variable "access_key" {}
variable "secret_key" {}
variable "key_name" {}
variable "name" {
    default = "lab"
}
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}
variable "region" {
    default = "us-east-1"
}
variable "vpn_base_ami" {
    default = "ami-c80b0aa2"
}
variable "vpn_instance_type" {
    default = "t2.small"
}

variable "vpn_psk" {
    description = "Pre-Shared Key for VPN"
}

variable "vpn_user" {
    default = "lab"
    description = "VPN User"
}

variable "vpn_password" {
    description = "Password for VPN user"
}
