variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.2.200.0/24", "10.2.190.0/24"]
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.2.25.0/24", "10.2.35.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}
variable "ami_data" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}
variable "disk_size" {
  type    = number
  default = 20
}
variable "eks_version" {
  type    = string
  default = "1.31"
}

# variable "subnet_private_ids" {
#   type = list(string)
# }

# variable "subnet_public_ids" {
#   type = list(string)
# }

variable "flask_name" {
  type    = string
  default = "flask-network"
}

variable "region" {
  type    = string
  default = "us-east-1"
}