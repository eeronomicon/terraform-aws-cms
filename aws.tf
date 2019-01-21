resource "aws_iam_role" "website-role-ec2" {
  name        = "website-role-ec2"
  description = "EC2 role to permit SSM management"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name = "website-role-ec2"
  }
}

resource "aws_iam_role_policy_attachment" "website-role-ec2-policy-attachment" {
  role       = "${aws_iam_role.website-role-ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_key_pair" "website-ec2-key" {
  key_name   = "${var.aws_ec2_keypair_name}"
  public_key = "${file("./templates/ec2-key.pub")}"
}

resource "aws_acm_certificate" "website-cert" {
  domain_name       = "${var.aws_acm_cert_domain}"
  validation_method = "DNS"

  tags = {
    Environment = "production"
  }

  lifecycle {
    create_before_destroy = true
  }
}
