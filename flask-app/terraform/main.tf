provider "aws" {
  alias  = "eks"
  region = var.region
}

module "networking_flask" {
  source              = "./modules/networking"
  flask_name          = "flask-network"
  vpc_cidr            = "10.2.0.0/16"
  public_subnet_cidr  = ["10.2.200.0/24", "10.2.190.0/24"]
  private_subnet_cidr = ["10.2.25.0/24", "10.2.35.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

module "eks_flask" {
  source             = "./modules/eks-flask"
  flask_name          = "flask-network"
  ami_type           = "AL2_x86_64"
  instance_types     = ["t2.micro"]
  capacity_type      = "ON_DEMAND"
  disk_size          = 20
  eks_version        = "1.31"
  subnet_private_ids = module.networking_flask.aws_subnet_private_ids
  subnet_public_ids  = module.networking_flask.aws_subnet_public_ids
  aws_vpc_id = module.networking_flask.aws_vpc_id
  providers = {
    aws = aws.eks
  }
  depends_on = [module.networking_flask]
}

# module "iamroles_flask" {
#   source = "./modules/iam-resources"
# }