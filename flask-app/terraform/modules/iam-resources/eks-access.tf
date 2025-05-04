# # Role used for accessing clusters
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