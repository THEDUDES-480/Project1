terraform {
    backend  "s3" {
    region         = "us-west-2"
    bucket         = "citprojects"
    key            = "terraform.tfstate"
    dynamodb_table = "state-lock"
    }
} 

resource "aws_s3_bucket" "project" {
  bucket = "citprojects"

  versioning {
    enabled = true
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "dynamodb-tf-state-lock" {
  name            = "state-lock"
  hash_key        = "LockID"
  read_capacity   = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "DynamoDB tf state locking"
  }
} 
