output "aws_subnet_public_ids" {
  value = module.networking_flask.aws_subnet_public_ids
}

output "aws_subnet_private_ids" {
  value = module.networking_flask.aws_subnet_private_ids
}

output "aws_vpc" {
  value = module.networking_flask.aws_vpc_id
}