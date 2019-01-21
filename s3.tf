resource "aws_s3_bucket" "website-s3-media" {
  bucket = "${var.aws_s3_bucket_name}"
  acl    = "public-read"
  region = "${var.aws_region}"

  tags = {
    Name = "${var.aws_s3_bucket_name}"
  }
}

resource "aws_vpc_endpoint" "website-vpcendpoint-s3" {
  vpc_id       = "${aws_vpc.website-vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "website-vpcendpointroute-s3" {
  route_table_id  = "${aws_route_table.website-route-private.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.website-vpcendpoint-s3.id}"
}
