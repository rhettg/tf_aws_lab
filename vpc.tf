resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"

    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "${var.name}"
        Environment = "${var.name}"
    }
}

resource "aws_vpc_dhcp_options" "main" {
    domain_name_servers = ["${cidrhost(cidrsubnet(var.vpc_cidr, 8, 0),2)}"]
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
    cidr_block = "${cidrsubnet(var.vpc_cidr, 8, 1)}"
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
