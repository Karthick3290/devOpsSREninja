# name
# cluster iam role -> permission, trusted entities (AmazonEKSAutoClusterRole)
# kubernetes version
# cluster access -> how iam principles access cluster (read about this)
# networking -> vpc,subnet, security groups
# cluster endpoint access -> private,public or both with cidr block

# # Role used for accessing clusters
# resource "aws_iam_role" "eks_cluster_role" {
#   name               = "flask-eks-iam-role"
#   assume_role_policy = <<POLICY
#   {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
#   tags = {
#     name = "flask-eks-iam-role"
#   }
# }

# resource "aws_iam_role_policy_attachment" "flask_eks_cluster_policy" {
#   role       = aws_iam_role.eks_cluster_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }

data "aws_iam_role" "eks_iam_role" {
  name = "flask-eks-iam-role"
}

resource "aws_eks_cluster" "flask_eks_cluster" {
  name     = "flask-eks-cluster"
  role_arn = data.aws_iam_role.eks_iam_role.arn
  version  = var.eks_version
  
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids = [aws_security_group.eks_cluster_sg.id]

    subnet_ids = concat(
      var.subnet_private_ids,
      var.subnet_public_ids
    )
  }
}

resource "aws_security_group" "eks_cluster_sg" {
  name = "eks-cluster-sg"
  description = "EKS Cluster security group"
  vpc_id = var.aws_vpc_id
}

resource "aws_security_group_rule" "cluster_ingress_from_node" {
  type = "ingress"
  description = "Allow nodes to communicate with control plane"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
}