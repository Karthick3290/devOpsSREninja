# name
# cluster iam role -> permission, trusted entities (AmazonEKSAutoClusterRole)
# kubernetes version
# cluster access -> how iam principles access cluster (read about this)
# networking -> vpc,subnet, security groups
# cluster endpoint access -> private,public or both with cidr block

resource "aws_eks_cluster" "flask_eks_cluster" {
  name     = "flask-eks-cluster"
  role_arn = var.role_arn
  version  = var.eks_version
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = concat(
      var.subnet_private_ids,
      var.subnet_public_ids
    )
  }
  # depends_on = [aws_iam_role_policy_attachment.flask_eks_cluster_policy]
}