
# data "aws_iam_role" "nodes_iam_role" {
#   name = "flask-nodes-iam-role"
# }

# Role used to access nodes

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
    "kubernetes.io/cluster/${aws_eks_cluster.flask_eks_cluster.name}" = "owned"
  }
  depends_on = [ aws_security_group.eks_cluster_sg ]
}

resource "aws_launch_template" "node-template" {
  name = "flask-eks-launch-nodes"
  image_id = var.ami_type
  instance_type  = var.instance_types
  
  vpc_security_group_ids = [
    aws_security_group.eks_nodes_sg.id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = join("-", [var.flask_name, "node"])
    }
  }

}

resource "aws_eks_node_group" "flask_eks_nodegroup" {
  cluster_name    = aws_eks_cluster.flask_eks_cluster.name
  node_group_name = "flask-worked-node-group"
  node_role_arn   = data.aws_iam_role.nodes_iam_role.arn
  subnet_ids      = var.subnet_private_ids
  capacity_type   = var.capacity_type
  scaling_config {
    max_size     = 3
    min_size     = 1
    desired_size = 2
  }

  depends_on = [
    aws_launch_template.node-template,
    aws_iam_role_policy_attachment.flask_EC2_ECRPolicy,
    aws_iam_role_policy_attachment.flask_EKSCNIPolicy,
    aws_iam_role_policy_attachment.flask_EKSWorkerNodePolicy
  ]
}