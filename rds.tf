resource "aws_db_subnet_group" "website-db-subnetgroup" {
  name        = "website-db-subnetgroup"
  description = "Subnet group for website application database"
  subnet_ids  = ["${aws_subnet.website-subnet-private-a.id}", "${aws_subnet.website-subnet-private-b.id}"]

  tags = {
    Name = "website-db-subnetgroup"
  }
}

resource "aws_db_instance" "website-db-instance" {
  allocated_storage                   = 20
  auto_minor_version_upgrade          = "true"
  availability_zone                   = "${element(var.aws_region_azs, 0)}"
  backup_retention_period             = "7"
  backup_window                       = "08:58-09:28"
  copy_tags_to_snapshot               = "true"
  db_subnet_group_name                = "${aws_db_subnet_group.website-db-subnetgroup.name}"
  deletion_protection                 = "true"
  domain                              = ""
  domain_iam_role_name                = ""
  engine                              = "mysql"
  engine_version                      = "5.6.40"
  iam_database_authentication_enabled = "false"
  identifier                          = "website-db-instance"
  instance_class                      = "${var.aws_ec2_instance_type["database"]}"
  iops                                = "0"
  kms_key_id                          = ""
  license_model                       = "general-public-license"
  maintenance_window                  = "wed:09:45-wed:10:15"
  monitoring_interval                 = "0"
  multi_az                            = "false"
  name                                = "website_database"
  option_group_name                   = "default:mysql-5-6"
  parameter_group_name                = "default.mysql5.6"
  port                                = "3306"
  publicly_accessible                 = "false"
  skip_final_snapshot                 = "true"
  storage_encrypted                   = "false"
  storage_type                        = "gp2"
  timezone                            = ""

  username = "${var.aws_rds_dbadmin_username}"
  password = "${var.aws_rds_dbadmin_password}"

  vpc_security_group_ids = [
    "${aws_security_group.website-sg-db.id}",
  ]

  tags = {
    Name = "website-db-instance"
  }
}
