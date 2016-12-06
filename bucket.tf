data "template_file" "bucket_policy" {
    template = "${file("${path.module}/s3_policy.json")}"

    vars {
        vpc_id = "${aws_vpc.main.id}"
        bucket_name = "${coalesce(var.lab_bucket_name, format("%s-lab-bucket", var.name))}"
    }
}

resource "aws_vpc_endpoint" "bucket" {
    vpc_id = "${aws_vpc.main.id}"
    service_name = "com.amazonaws.${aws_s3_bucket.lab.region}.s3"
    route_table_ids = ["${aws_route_table.public.id}"]
}

resource "aws_s3_bucket" "lab" {
    bucket = "${coalesce(var.lab_bucket_name, format("%s-lab-bucket", var.name))}"
    force_destroy = true

    acl = "private"
    policy = "${data.template_file.bucket_policy.rendered}"

    tags {
        Environment = "${var.name}"
    }
}
