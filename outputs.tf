output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "vpn_instance_id" {
  value = "${aws_instance.vpn.id}"
}

output "subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "subnet_cidr" {
  value = "${aws_subnet.public.cidr_block}"
}

output "subnet_az" {
  value = "${aws_subnet.public.availability_zone}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "zone_id" {
  value = "${aws_route53_zone.main.id}"
}

output "domain" {
  value = "${aws_route53_zone.main.name}"
}

output "bucket_name" {
  value = "${aws_s3_bucket.lab.bucket}"
}

output "bucket_url" {
  value = "https://s3.amazonaws.com/${aws_s3_bucket.lab.bucket}"
}

output "vpn_ip" {
  value = "${aws_instance.vpn.public_ip}"
}

output "vpn_sharedkey" {
  value = "${data.template_file.vpn_user_data.vars.vpn_psk}"
}

output "vpn_user" {
  value = "${data.template_file.vpn_user_data.vars.vpn_xauth_user}"
}

output "vpn_password" {
  value = "${data.template_file.vpn_user_data.vars.vpn_xauth_password}"
}
