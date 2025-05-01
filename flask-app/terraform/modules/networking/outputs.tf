output "aws_subnet_public_ids" {
  description = "Public Subnet ID's"
  value = aws_subnet.public_subnets.*.id
}

output "aws_subnet_private_ids" {
  description = "Private Subnet ID's"
  value = aws_subnet.private_subnets.*.id
}

output "aws_vpc_id" {
  description = "VPC ID"
  value = aws_vpc.network-vpc.id
}