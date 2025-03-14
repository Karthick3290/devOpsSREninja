# resource "aws_subnet" "public_subnet_1" {
#   vpc_id            = aws_vpc.network-vpc.id
#   availability_zone = "us-east-1a"
#   cidr_block        = "10.1.0.0/24"
#   tags = {
#     Name = "network-subnet-1"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id            = aws_vpc.network-vpc.id
#   availability_zone = "us-east-1b"
#   cidr_block        = "10.1.1.0/24"
#   tags = {
#     Name = "network-subnet-2"
#   }
# }

# resource "aws_subnet" "private_subnet_1" {
#   vpc_id            = aws_vpc.network-vpc.id
#   availability_zone = "us-east-1a"
#   cidr_block        = "10.1.2.0/24"
#   tags = {
#     Name = "network-private-subnet-1"
#   }
# }

# resource "aws_subnet" "private_subnet_2" {
#   vpc_id            = aws_vpc.network-vpc.id
#   availability_zone = "us-east-1b"
#   cidr_block        = "10.1.3.0/24"
#   tags = {
#     Name = "network-private-subnet-2"
#   }
# }

# resource "aws_nat_gateway" "network-nat-1" {
#   subnet_id = aws_subnet.private_subnet_1.id
#   allocation_id = aws_eip.eip-1.id
#  tags = {
#    Name = "network-nat-gw-1"
#  }
#  depends_on = [ aws_internet_gateway.network-igw]
# }

# resource "aws_nat_gateway" "network-nat-2" {
#   subnet_id = aws_subnet.private_subnet_2.id
#   allocation_id = aws_eip.eip-2.id
#   tags = {
#     Name = "network-nat-gw-2"
#   }
#   depends_on = [ aws_internet_gateway.network-igw ]
# }

# resource "aws_eip" "eip-1" {
#   tags = {
#     Name = "network-eip-1"
#   }
# }

# resource "aws_eip" "eip-2" {
#   tags = {
#     Name = "network-eip-1"
#   }
# }


# resource "aws_route_table" "network-route-private-1" {
#   vpc_id = aws_vpc.network-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.network-nat-1.id
#   }
#   tags = {
#     Name = "route-table-private-1"
#   }
# }

# resource "aws_route_table" "network-route-private-2" {
#   vpc_id = aws_vpc.network-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.network-nat-2.id
#   }
#   tags = {
#     Name = "route-table-private-2"
#   }
# }

# resource "aws_route_table_association" "network-route-1-association" {
#   subnet_id = aws_subnet.private_subnet_1.id
#   route_table_id = aws_route_table.network-route-private-1.id
# }

# resource "aws_route_table_association" "network-route-2-association" {
#   subnet_id = aws_subnet.private_subnet_2.id
#   route_table_id = aws_route_table.network-route-private-2.id
# }

resource "aws_vpc" "network-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "flask-network-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.network-vpc.id
  availability_zone = element(var.availability_zones,count.index)
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
    Name = "flask-network-igw"
  }
}

resource "aws_nat_gateway" "network-nat" {
  count = length(var.private_subnet_cidr)
  subnet_id = aws_subnet.private_subnets[count.index].id
  allocation_id = aws_eip.network-eip[count.index].id
  tags = {
   Name = "network-nat-gw ${count.index + 1}"
 }
 depends_on = [ aws_internet_gateway.network-igw]
}

resource "aws_eip" "network-eip" {
  count = length(var.private_subnet_cidr)
  tags = {
    Name = "flask-network-eip ${count.index + 1}"
  }
}

resource "aws_route_table" "network-route-private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.network-vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.network-nat[count.index].id
  }
  tags = {
    Name = "flask-route-private ${count.index + 1}"
  }
  depends_on = [ aws_nat_gateway.network-nat ]
}

resource "aws_route_table_association" "network-route-association" {
  count = length(var.private_subnet_cidr)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.network-route-private[count.index].id
}

resource "aws_route_table" "network-route-public" {
  vpc_id = aws_vpc.network-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.network-igw.id
  }
  tags = {
    Name = "flask-route-table-public"
  }
  depends_on = [ aws_internet_gateway.network-igw ]
}

resource "aws_route_table_association" "network-public_subnet_igw" {
  count = length(var.public_subnet_cidr)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.network-route-public.id
}