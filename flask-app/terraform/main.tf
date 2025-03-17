module "networking_flask" {
  source = "./modules/networking"
  vpc_cidr = "10.2.0.0/16"
  public_subnet_cidr = [ "10.2.200.0/24","10.2.190.0/24" ]
  private_subnet_cidr = [ "10.2.25.0/24","10.2.35.0/24" ]
  availability_zones = [ "us-east-1a","us-east-1b" ]
}