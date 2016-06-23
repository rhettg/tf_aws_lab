variable "key_name" {
    description = "Key pair name to create VPN instance with"
    default = ""
}

variable "name" {
    default = "lab"
}

variable "lab_bucket_name" {
    default = ""
    description = "S3 bucket name"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "vpn_base_ami" {
    default = "ami-c80b0aa2"
}

variable "vpn_instance_type" {
    default = "t2.small"
}

variable "vpn_psk" {
    description = "Pre-Shared Key for VPN"
    default = ""
}

variable "vpn_subnet" {
    description = "Subnet to build for the VPN. Define if you need custom network layout"
    default = ""
}

variable "vpn_user" {
    description = "VPN User"
    default = ""
}

variable "vpn_password" {
    description = "Password for VPN user"
    default = ""
}
