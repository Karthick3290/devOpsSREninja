resource "aws_vpc" "network-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = join(var.name,"-","vpc")
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
