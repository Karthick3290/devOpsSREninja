variable "public_subnet_cidr" {
  type = list(string)
  default = [ "10.2.200.0/24","10.2.190.0/24" ]
}

variable "private_subnet_cidr" {
  type = list(string)
  default = [ "10.2.25.0/24","10.2.35.0/24" ]
}

variable "availability_zones" {
  type = list(string)
  default = [ "us-east-1a","us-east-1b" ]
}

variable "vpc_cidr" {
  type = string
  default = "10.2.0.0/16"
}