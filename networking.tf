resource "aws_vpc" "sneakyendpoints_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sneakyendpoints_vpc"
  }
}

resource "aws_subnet" "sneakyendpoints_private_subnet" {
  vpc_id                  = aws_vpc.sneakyendpoints_vpc.id
  availability_zone       = "${var.region}a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sneakyendpoints_subnet"
  }
}

resource "aws_internet_gateway" "sneakyendpoints_igw" {
  vpc_id = aws_vpc.sneakyendpoints_vpc.id

  tags = {
    Name = "sneakyendpoints_internet_gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sneakyendpoints_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sneakyendpoints_igw.id
  }
  
  tags = {
    Name = "sneakyendpoints_public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.sneakyendpoints_public_subnet.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "sneakyendpoints_route_table" {
  vpc_id = aws_vpc.sneakyendpoints_vpc.id

  tags = {
    Name = "sneakyendpoints_route_table"
  }
}

resource "aws_main_route_table_association" "sneakyendpoints_private_route_table_association" {
  vpc_id         = aws_vpc.sneakyendpoints_vpc.id
  route_table_id = aws_route_table.sneakyendpoints_route_table.id
}

# Requires https - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow 443/tcp inbound"
  vpc_id      = aws_vpc.sneakyendpoints_vpc.id

  ingress {
    description = "Allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags = {
    Name = "allow_https"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.sneakyendpoints_public_subnet.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sneakyendpoints_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.sneakyendpoints_private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "sneakyendpoints_public_subnet" {
  vpc_id                  = aws_vpc.sneakyendpoints_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "sneakyendpoints_public_subnet"
  }
}