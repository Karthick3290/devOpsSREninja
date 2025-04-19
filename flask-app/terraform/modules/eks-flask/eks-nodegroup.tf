
# data "aws_iam_role" "nodes_iam_role" {
#   name = "flask-nodes-iam-role"
# }

# resource "aws_eks_node_group" "flask_eks_nodegroup" {
#   cluster_name    = aws_eks_cluster.flask_eks_cluster.name
#   node_group_name = "flask-worked-node-group"
#   node_role_arn   = data.aws_iam_role.nodes_iam_role.arn
#   subnet_ids      = var.subnet_private_ids
#   ami_type        = var.ami_type
#   instance_types  = var.instance_types
#   capacity_type   = var.capacity_type
#   disk_size       = var.disk_size

#   scaling_config {
#     max_size     = 3
#     min_size     = 1
#     desired_size = 2
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.flask_EC2_ECRPolicy,
#     aws_iam_role_policy_attachment.flask_EKSCNIPolicy,
#     aws_iam_role_policy_attachment.flask_EKSWorkerNodePolicy
#   ]
# }