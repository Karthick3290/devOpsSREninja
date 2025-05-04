resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.flask_eks_cluster.name
  addon_name = "coredns"
  addon_version = "v1.11.4-eksbuild.2"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [ aws_eks_node_group.flask_eks_nodegroup ]
}