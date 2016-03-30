provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "${var.name}"
        Environment = "${var.name}"
    }
}

resource "aws_vpc_dhcp_options" "main" {
    domain_name_servers = ["10.0.0.2"]
    domain_name = "${var.name}"

    tags {
        Name = "${var.name}"
        Environment = "${var.name}"
    }
}

resource "aws_vpc_dhcp_options_association" "main" {
    vpc_id = "${aws_vpc.main.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
}

resource "aws_route53_zone" "main" {
    name = "${var.name}"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Environment = "${var.name}"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "${var.name}"
        Environment = "${var.name}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"
    tags {
        Name = "${var.name}-public"
        Environment = "${var.name}"
    }
}

resource "aws_route" "public_internet_gateway" {
    route_table_id = "${aws_route_table.public.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.name}-public"
        Environment = "${var.name}"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "vpn" {
    name = "${var.name}-vpn-sg"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Environment = "${var.name}"
    }

    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 500
        to_port = 500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 4500
        to_port = 4500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "vpn" {
    ami = "ami-c80b0aa2"
    instance_type = "t2.small"

    subnet_id = "${aws_subnet.public.id}"
    vpc_security_group_ids = ["${aws_security_group.vpn.id}"]
    associate_public_ip_address = true

    key_name = "${var.key_name}"

    user_data = "${file(\"vpn_user_data.sh\")}"

    tags {
        Name = "vpn0-${var.name}"
        Environment = "${var.name}"
    }
}

resource "aws_route53_record" "vpn0" {
   zone_id = "${aws_route53_zone.main.zone_id}"
   name = "vpn0.${var.name}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.vpn.private_ip}"]
}
