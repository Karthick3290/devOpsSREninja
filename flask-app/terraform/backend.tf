terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "flask-tfstate"
    region         = "us-east-1"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-locks"
    # use_lockfile = true
  }
}