# VPC

resource "aws_vpc" "c1_vpc" {
  cidr_block = "10.100.0.0/16"
}

# Subnet

resource "aws_subnet" "c1_public_subnet" {
  vpc_id     = aws_vpc.c1_vpc.id
  cidr_block = "10.100.0.0/24"
}


# IGW

resource "aws_internet_gateway" "c1_igw" {
  vpc_id = aws_vpc.c1_vpc.id
}

# Route table

resource "aws_route_table" "c1_rt" {
  vpc_id = aws_vpc.c1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.c1_igw.id
  }

  route {
    cidr_block = "10.100.0.0/16"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "c1_public_subnet_association" {
  subnet_id      = aws_subnet.c1_public_subnet.id
  route_table_id = aws_route_table.c1_rt.id
}

# Security groups

resource "aws_security_group" "c1_sg" {
  name        = "challenge1_sg"
  description = "Allow HTTP/HTTPS, SSH inbound and internet outbound traffic to challenge-1 EC2 instance"
  vpc_id      = aws_vpc.c1_vpc.id


}

resource "aws_vpc_security_group_ingress_rule" "c1_ssh_ec2_rule" {
  security_group_id = aws_security_group.c1_sg.id
  cidr_ipv4         = "159.196.169.214/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "c1_http_ec2_rule" {
  security_group_id = aws_security_group.c1_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "c1_https_ec2_rule" {
  security_group_id = aws_security_group.c1_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "c1_api_dev_ec2_rule" {
  security_group_id = aws_security_group.c1_sg.id
  cidr_ipv4        = "159.196.169.214/32"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.c1_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# NACL
resource "aws_network_acl" "c1_nacl" {
  vpc_id     = aws_vpc.c1_vpc.id
  subnet_ids = [aws_subnet.c1_public_subnet.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "159.196.169.214/32"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "159.196.169.214/32"
    from_port  = 3000
    to_port    = 3000
  }
  ingress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}


