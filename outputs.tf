output "vpn_ip" {
  value = "${aws_instance.vpn.public_ip}"
}
