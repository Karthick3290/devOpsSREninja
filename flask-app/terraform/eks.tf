# name
# cluster iam role -> permission, trusted entities (AmazonEKSAutoClusterRole)
# kubernetes version
# cluster access -> how iam principles access cluster (read about this)
# networking -> vpc,subnet, security groups
# cluster endpoint access -> private,public or both with cidr block

resource "aws_iam_role" "eks_cluster_role" {
  name               = "flask-eks-iam-role"
  assume_role_policy = <<POLICY
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    name = "flask-eks-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "flask_eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "flask_eks_cluster" {
  name     = "flask-eks-cluster"
  role_arn = aws_iam_role.eks_iam_role.arn
  version  = "1.31"
  vpc_config {
    subnet_ids = concat(
      module.networking_flask.aws_subnet_private_ids,
      module.networking_flask.aws_subnet_public_ids
    )
  }

  depends_on = [aws_iam_role_policy_attachment.flask_eks_cluster_policy]
}

resource "aws_iam_role" "nodes_iam_role" {
  name               = "flask-nodes-iam-role"
  assume_role_policy = <<POLICY
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    name = "flask-nodes-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "flask_EKSWorkerNodePolicy" {
  role       = aws_iam_role.nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "flask_EKSCNIPolicy" {
  role       = aws_iam_role.nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "flask_EC2_ECRPolicy" {
  role       = aws_iam_role.nodes_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "flask_eks_nodegroup" {
  cluster_name    = aws_eks_cluster.flask_eks_cluster.name
  node_group_name = "flask-worked-node-group"
  node_role_arn   = aws_iam_role.nodes_iam_role.arn
  subnet_ids      = module.networking_flask.aws_subnet_public_ids
  ami_type        = "AL2_x86_64"
  instance_types  = ["t3.micro"]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20

  scaling_config {
    max_size     = 3
    min_size     = 1
    desired_size = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.flask_EC2_ECRPolicy,
    aws_iam_role_policy_attachment.flask_EKSCNIPolicy,
    aws_iam_role_policy_attachment.flask_EKSWorkerNodePolicy
  ]
}