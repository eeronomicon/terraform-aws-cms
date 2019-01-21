variable "aws_region" {
  default = "us-west-1"
}

variable "aws_region_azs" {
  default = [
    "us-west-1a",
    "us-west-1b",
  ]
}

variable "aws_profile" {
  default = "freeformportland"
}

variable "aws_s3_bucket_name" {
  default = "media.freeformportland.org"
}

variable "aws_acm_cert_domain" {
  default = "*.freeformportland.org"
}

variable "aws_ec2_keypair_name" {
  default = "freeformportland-uswest-1"
}

variable "aws_vpc_cidr_block" {
  default = "10.10.0.0/16"
}

variable "aws_vpc_subnet_cidrs" {
  default = {
    "public-a"  = "10.10.11.0/24"
    "public-b"  = "10.10.12.0/24"
    "private-a" = "10.10.21.0/24"
    "private-b" = "10.10.22.0/24"
  }
}

variable "aws_ec2_instance_ami" {
  default = {
    "webserver" = "ami-0799ad445b5727125"
  }
}

variable "aws_ec2_instance_type" {
  default = {
    "webserver" = "t2.micro"
    "database"  = "db.t2.micro"
  }
}

variable "aws_rds_dbadmin_username" {
  default = "websitedbadmin"
}

variable "aws_rds_dbadmin_password" {}
