# resource "aws_iam_role" "nodes_iam_role" {
#   name               = "flask-nodes-iam-role"
#   assume_role_policy = <<POLICY
#   {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
#   tags = {
#     name = "flask-nodes-iam-role"
#   }
# }

# resource "aws_iam_role_policy_attachment" "flask_EKSWorkerNodePolicy" {
#   role       = aws_iam_role.nodes_iam_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "flask_EKSCNIPolicy" {
#   role       = aws_iam_role.nodes_iam_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "flask_EC2_ECRPolicy" {
#   role       = aws_iam_role.nodes_iam_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_eks_node_group" "flask_eks_nodegroup" {
#   cluster_name    = aws_eks_cluster.flask_eks_cluster.name
#   node_group_name = "flask-worked-node-group"
#   node_role_arn   = aws_iam_role.nodes_iam_role.arn
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