output "aws_subnet_public_ids" {
  value = module.networking_flask.aws_subnet_public_ids
}

output "aws_subnet_private_ids" {
  value = module.networking_flask.aws_subnet_private_ids
}

# output "eks_cluster_role_arn" {
#   value = module.iamroles_flask.eks_cluster_role_arn
# }