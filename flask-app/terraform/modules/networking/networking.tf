resource "aws_vpc" "network-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = join("-", [var.flask_name, "vpc"])
  } 
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.network-vpc.id
  availability_zone = element(var.availability_zones,count.index)
  map_public_ip_on_launch = true
  cidr_block = element(var.public_subnet_cidr,count.index)
  tags = {
    Name = "flask-network-subnet-public ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.network-vpc.id
  availability_zone = element(var.availability_zones,count.index)
  cidr_block = element(var.private_subnet_cidr,count.index)
  tags = {
    Name = "flask-network-subnet-private ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "network-igw" {
  vpc_id = aws_vpc.network-vpc.id
  tags = {
    Name = join("-", [var.flask_name, "igw"])
  }
}

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }


resource "aws_instance" "nat-instance" {
  ami = var.ami_data
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnets[0].id
  # vpc_security_group_ids = 
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = join("-", [var.flask_name, "nat-instance"])
  }
}

# NAT gateway for a subnet -> cons (increased cost)
# resource "aws_nat_gateway" "network-nat" {
#   count = length(var.private_subnet_cidr)
#   subnet_id = aws_subnet.private_subnets[count.index].id
#   allocation_id = aws_eip.network-eip[count.index].id
#   tags = {
#    Name = "network-nat-gw ${count.index + 1}"
#  }
#  depends_on = [ aws_internet_gateway.network-igw]
# }

# resource "aws_eip" "network-eip" {
#   count = length(var.private_subnet_cidr)
#   tags = {
#     Name = "flask-network-eip ${count.index + 1}"
#   }
# }

resource "aws_route_table" "network-route-private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.network-vpc.id
  # NAT gateway routing
  # route {
  #    cidr_block = "0.0.0.0/0"
  #    gateway_id = aws_nat_gateway.network-nat[count.index].id
  # }
  tags = {
    Name = "flask-route-private ${count.index + 1}"
  }
  # depends_on = [ aws_nat_gateway.network-nat ]
}

resource "aws_route_table_association" "network-route-association" {
  count = length(var.private_subnet_cidr)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.network-route-private[count.index].id
}
# Routing for NAT instance
resource "aws_route" "outbound-nat-route" {
  count = length(var.private_subnet_cidr)
  route_table_id = aws_route_table.network-route-private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.nat-instance.primary_network_interface_id
}

resource "aws_security_group" "nat-instance-sg" {
  description = "security group for nat instance"
  vpc_id = aws_vpc.network-vpc.id
  tags = {
    Name = join("-", [var.flask_name, "nat-instance-sg"])
  }
}

resource "aws_security_group_rule" "vpc-inbound" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [var.vpc_cidr]
  security_group_id = aws_security_group.nat-instance-sg.id
}

resource "aws_security_group_rule" "nat-instance-private" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = var.private_subnet_cidr
  security_group_id = aws_security_group.nat-instance-sg.id
}

resource "aws_security_group_rule" "nat-instance-private-HTTPS" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = var.private_subnet_cidr
  security_group_id = aws_security_group.nat-instance-sg.id
}

resource "aws_security_group_rule" "outbound-nat-instance" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat-instance-sg.id
}

resource "aws_route_table" "network-route-public" {
  vpc_id = aws_vpc.network-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.network-igw.id
  }
  tags = {
    Name = join("-",[var.flask_name,"route-table-public"])
  }
  depends_on = [ aws_internet_gateway.network-igw ]
}

resource "aws_route_table_association" "network-public_subnet_igw" {
  count = length(var.public_subnet_cidr)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.network-route-public.id
}