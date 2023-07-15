resource "aws_instance" "sneakyendpoints_host" {
  ami                    = data.aws_ami.base_ami.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.sneakyendpoints_private_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_https.id]
  iam_instance_profile   = aws_iam_instance_profile.sneakyendpoints_profile.name

  depends_on = [
    aws_vpc_endpoint.ec2messages_vpce,
    aws_vpc_endpoint.ssmmessages_vpce,
    aws_vpc_endpoint.ssm_vpce,
    aws_vpc_endpoint_subnet_association.ec2messages_vpce_association,
    aws_vpc_endpoint_subnet_association.ssmmessages_vpce_association,
    aws_vpc_endpoint_subnet_association.ssm_vpce_association,
    aws_iam_instance_profile.sneakyendpoints_profile,
  ]

  tags = {
    Name = "sneakyendpoints_host"
  }
}

resource "aws_iam_role" "sneakyendpoints_role" {
  name                = "sneakyendpoints_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "sneakyendpoints_profile" {
  name = "sneakyendpoints_instance_profile"
  role = aws_iam_role.sneakyendpoints_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.sneakyendpoints_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_ami" "base_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.base_ami_filter_value]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = [var.base_ami_owner_id]
}