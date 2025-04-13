#!/bin/bash

set -e

echo "Checking and importing resources if they already exist..."

# S3 Bucket
BUCKET_NAME="flask-aws-tfstate"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "S3 bucket $BUCKET_NAME exists. Importing..."
  terraform import aws_s3_bucket.tfstate "$BUCKET_NAME"
else
  echo "S3 bucket $BUCKET_NAME does not exist. Skipping import."
fi

# IAM Role
ROLE_NAME="flask-eks-iam-role"
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text 2>/dev/null || true)
if [ -n "$ROLE_ARN" ]; then
  echo "IAM Role $ROLE_NAME exists. Importing..."
  terraform import aws_iam_role.eks_cluster_role "$ROLE_NAME"
else
  echo "IAM Role $ROLE_NAME does not exist. Skipping import."
fi

# Add more resources below similarly...
