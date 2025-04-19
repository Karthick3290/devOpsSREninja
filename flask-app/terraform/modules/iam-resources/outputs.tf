output "eks-cluster-role-arn" {
  description = "Passing the cluster role arn"
  value = aws_iam_role.eks_cluster_role.arn
}