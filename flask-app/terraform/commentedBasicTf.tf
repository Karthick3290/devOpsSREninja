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