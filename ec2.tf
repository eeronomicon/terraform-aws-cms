resource "aws_iam_instance_profile" "website-appserver-profile" {
  name = "website-appserver-profile"
  role = "${aws_iam_role.website-role-ec2.name}"
}

resource "aws_instance" "website-appserver-instance" {
  ami                         = "${var.aws_ec2_instance_ami["webserver"]}"
  associate_public_ip_address = false
  availability_zone           = "${element(var.aws_region_azs, 0)}"
  disable_api_termination     = false
  ebs_optimized               = false
  get_password_data           = false
  iam_instance_profile        = "${aws_iam_instance_profile.website-appserver-profile.name}"
  instance_type               = "${var.aws_ec2_instance_type["webserver"]}"
  key_name                    = "${aws_key_pair.website-ec2-key.key_name}"
  monitoring                  = false
  placement_group             = ""
  source_dest_check           = true
  subnet_id                   = "${aws_subnet.website-subnet-private-a.id}"
  tenancy                     = "default"
  user_data                   = "${file("./templates/ec2-userdata.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.website-sg-appserver.id}",
  ]

  volume_tags = {
    Name = "website-appserver-instance"
  }

  tags = {
    Name = "website-appserver-instance"
  }
}

resource "aws_lb_target_group_attachment" "website-appserver-instance-tg" {
  target_group_arn = "${aws_lb_target_group.website-alb-tg.arn}"
  target_id        = "${aws_instance.website-appserver-instance.id}"
  port             = 80
}

resource "aws_lb" "website-alb" {
  name                       = "website-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.website-sg-alb.id}"]
  enable_deletion_protection = false

  subnets = [
    "${aws_subnet.website-subnet-public-a.id}",
    "${aws_subnet.website-subnet-public-b.id}",
  ]

  enable_deletion_protection = false

  tags = {
    Name = "website-alb"
  }
}

resource "aws_lb_target_group" "website-alb-tg" {
  name     = "website-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.website-vpc.id}"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.website-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.website-cert.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.website-alb-tg.arn}"
  }
}

resource "aws_launch_template" "website-appserver-lt" {
  name_prefix   = "website-appserver"
  image_id      = "${var.aws_ec2_instance_ami["webserver"]}"
  instance_type = "${var.aws_ec2_instance_type["webserver"]}"
}

resource "aws_autoscaling_group" "website-appserver-asg" {
  vpc_zone_identifier = [
    "${aws_subnet.website-subnet-private-a.id}",
    "${aws_subnet.website-subnet-private-b.id}",
  ]

  desired_capacity = 0
  max_size         = 0
  min_size         = 0

  target_group_arns = [
    "${aws_lb_target_group.website-alb-tg.arn}",
  ]

  launch_template = {
    id      = "${aws_launch_template.website-appserver-lt.id}"
    version = "$$Latest"
  }
}
