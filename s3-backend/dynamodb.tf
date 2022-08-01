resource "aws_dynamodb_table" "dynamodb_table" {
  name = "${var.namespace}-state-lock"

  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  # LockID -> Save locking state
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    ResourceGroup = var.namespace
  }
}