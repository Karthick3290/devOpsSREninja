terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "flask-app-ninja-tfstate"
    dynamodb_table = "terraform-state-locking"
    region         = "us-east-1"
    key            = "terraform.tfstate"
  }
}