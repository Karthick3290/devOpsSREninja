# name
# cluster iam role -> permission, trusted entities (AmazonEKSAutoClusterRole)
# kubernetes version
# cluster access -> how iam principles access cluster (read about this)
# networking -> vpc,subnet, security groups
# cluster endpoint access -> private,public or both with cidr block

resource "aws_iam_role" "eks_iam_role" {
  name = "flask-eks-iam-role"
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

resource "aws_iam_role_policy_attachment" "eks_iam_policy_attachment" {
    role = aws_iam_role.eks_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "flask_eks_cluster" {
  name = "flask-eks-cluster"
  role_arn = aws_iam_role.eks_iam_role.arn
  version = "1.31"
  vpc_config {
    subnet_ids = [concat(
        module.networking_flask.aws_subnet_public_ids,
        module.networking_flask.aws_subnet_public_ids
    )
    ]
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_iam_policy_attachment]
}