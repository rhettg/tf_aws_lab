/*
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_instance" "test" {
    ami = "ami-c80b0aa2"
    instance_type = "t2.small"

    subnet_id = "${aws_subnet.public.id}"
    vpc_security_group_ids = ["${aws_security_group.vpn.id}"]
    associate_public_ip_address = true

    key_name = "${var.key_name}"

    tags {
        Name = "test0-${var.name}"
        Environment = "${var.name}"
    }
}

resource "aws_route53_record" "test0" {
   zone_id = "${aws_route53_zone.main.zone_id}"
   name = "test0.${var.name}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.test.private_ip}"]
}
*/
