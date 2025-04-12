provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "flask-tfstate"
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "table_state_locking" {
  name                        = "terraform-state-locking"
  hash_key                    = "LockID"
  billing_mode                = "PAY_PER_REQUEST"
  # deletion_protection_enabled = true
  attribute {
    name = "LockID"
    type = "S"
  }
}