terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "flask-aws-tfstate"
    region         = "us-east-1"
    key            = "terraform.tfstate"
    # dynamodb_table = "terraform-state-locking"
    use_lockfile = true
  }
}