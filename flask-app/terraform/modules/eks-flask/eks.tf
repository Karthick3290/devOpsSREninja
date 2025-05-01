# name
# cluster iam role -> permission, trusted entities (AmazonEKSAutoClusterRole)
# kubernetes version
# cluster access -> how iam principles access cluster (read about this)
# networking -> vpc,subnet, security groups
# cluster endpoint access -> private,public or both with cidr block

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

resource "aws_security_group" "eks_nodes_sg" {
  name = "allow_eks"
  description = "security group for nodes to be accessed by EKS"
  vpc_id = var.aws_vpc_id

# Allow incoming HTTPS from control plane SG
  ingress = [{
    description = "Allow control plane to talk to node kubelet"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
    cidr_blocks     = []                  
    ipv6_cidr_blocks = []                
    prefix_list_ids = []
    self            = false
  }]
  
  egress = [{
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  tags = {
    Name = "flask-eks-node-sg"
  }
  depends_on = [ aws_security_group.eks_cluster_sg ]
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