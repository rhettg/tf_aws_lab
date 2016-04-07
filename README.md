# tf_aws_lab

A Terraform module for creating a VPC Laboratory allowing you to connect to
your lab network using a IPSec VPN.

This is useful for quickly and securely building a development infrastructure
in AWS. It integrates with private Route53 so you'll get a complete domain and
DNS records inside your VPC.

## Input Variables

### Required

  Nothing. It just works

### Recommended

 * `key_name` Name of the key_pair to use for creating a VPN instance. (so you can ssh in)
 * `name` - Name for the lab. Becomes the domainname for the VPC as well as controls Environment labels.
 * `vpn_base_ami` - AMI to use in your region. Default assumes us-east-1 and ubuntu trusty.
 * `vpn_instance_type` - Defaults to `t2.small`

### Optional

 * `vpn_user` - Defaults to lab name
 * `vpn_password` - Default generates a uuid
 * `vpn_sharedkey` - Default generates a uuid
 * `vpc_cidr` - Network layout for the VPC. Defaults to 10.0.0.0/16
 * `vpn_subnet` - Where to build the main subnet. Defaults to 10.0.249.0/24

## Outputs

You'll likely need these to connect to your VPN:

  * `vpn_ip`
  * `vpn_user`
  * `vpn_password`
  * `vpn_sharedkey`

These will be useful for building additional resources:

  * `subnet_id`
  * `security_group_id`
  * `zone_id`
  * `domain`

You might also use:

  * `vpc_id`
  * `vpn_instance_id`
  * `bucket_name` - S3 Bucket name to stage data.
  * `bucket_url` - S3 URL you can use to pull resources out of the bucket


## Example

```
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

module "vpc_lab" {
    source = "github.com/rhettg/tf_aws_lab"
}

resource "aws_instance" "test" {
    ami = "ami-c80b0aa2"
    instance_type = "m3.medium"

    subnet_id = "${module.vpc_lab.subnet_id}"
    vpc_security_group_ids = ["${module.vpc_lab.security_group_id}"]
}

resource "aws_route53_record" "test" {
   zone_id = "${module.vpc_lab.zone_id}"
   name = "test.${module.vpc_lab.domain}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.test.private_ip}"]
}

output "vpn_ip" {
    value = "${module.vpc_lab.vpn_ip}"
}

output "vpn_sharedkey" {
    value = "${module.vpc_lab.vpn_sharedkey}"
}

output "vpn_user" {
    value = "${module.vpc_lab.vpn_user}"
}

output "vpn_password" {
    value = "${module.vpc_lab.vpn_password}"
}
```

This will create a VPC and include an instance called `vpn0`. You can then configure
your local VPN client to using "Cisco IPSec" with the generated user, password,
shared key and ip address.

After successfully connecting, you should be able to connect to any other
resource you create in the VPC.

    $ ping test.lab
    PING test.lab (10.0.249.113): 56 data bytes
    64 bytes from 10.0.249.113: icmp_seq=0 ttl=64 time=71.382 ms
    ...

## Uploading Data

While Terraform has "provisioners" such as file upload or script execution, you
can't really easily use them here because you'd have to be connected to your
VPN to connect to your hosts.

In a production environment you should likely be building images with Packer,
but for prototyping that's not a great workflow.

Doing all your provisioning with just user_data scripts can also work, but
you're limited to 16Kb.

To get around these limitations, tf_aws_lab has helpfully configured an S3
bucket your instances inside the VPC can access.

You can define resources that should exist in your bucket:

    resource "aws_s3_bucket_object" "lab_provision" {
        bucket = "${module.vpc_lab.bucket_name}"
        key = "lab.tgz"
        source = "build/lab.tgz"
        etag = "${md5(file(\"build/lab.tgz\"))}"
    }

To effectively use, you should add this to your instance:

    depends_on = ["aws_s3_bucket_object.lab_provision"]

Then you can templatize your user_data script such as:

    resource "template_file" "test_user_data" {
        count = 1
        template = "${file(\"test_user_data.sh\")}"

        vars {
            hostname = "test${count.index}"
            bucket_url = "${module.vpc_lab.bucket_url}"
        }
    }

And your `test_user_data.sh`

```
#!/bin/bash

set -e

echo "Setting hostname"

echo "${hostname}" > /etc/hostname
hostname -F /etc/hostname

cd /tmp
wget ${bucket_url}/lab.tgz
tar --no-same-owner -xzf lab.tgz
./provision.sh
```

The content you upload is of course up to you. A simple binary, a set of python
scripts, or even a full puppet manifest.


## Authors

Originally suggested by [@splaice](https://github.com/splaice), initial VPN
configuration by [@bickfordb](https://github.com/bickfordb) and terraform-fu by
[@rhettg](https://github.com/rhettg).
