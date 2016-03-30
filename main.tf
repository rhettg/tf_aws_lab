provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags {
        Name = "rhettg-lab"
    }
}

resource "aws_vpn_gateway" "vpn_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_customer_gateway" "customer_gateway" {
    bgp_asn = 60000
    ip_address = "172.0.0.1"
    type = "ipsec.1"
}

resource "aws_vpn_connection" "main" {
    vpn_gateway_id = "${aws_vpn_gateway.vpn_gateway.id}"
    customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
    type = "ipsec.1"
    static_routes_only = true
}

output "vpn_ip" {
    value = "${aws_vpn_connection.main.tunnel1_address}"
}

output "vpn_secret" {
    value = "${aws_vpn_connection.main.tunnel1_preshared_key}"
}
