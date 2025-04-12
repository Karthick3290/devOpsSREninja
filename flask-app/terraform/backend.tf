terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "flask-tfstate"
    dynamodb_table = "terraform-state-locking"
    region         = "us-east-1"
    key            = "terraform.tfstate"
  }
}