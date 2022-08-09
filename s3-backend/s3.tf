
# Create s3 bucket to store state files
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.namespace}-state-bucket"

  # Prevent accidental deletion s3
  # lifecycle {
  #   prevent_destroy = true
  # }
  tags = {
    ResourceGroup = var.namespace
  }
}

# Access control list (default)
resource "aws_s3_bucket_acl" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Turn on versioning
resource "aws_s3_bucket_versioning" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Using KMS (KMS encrypts only the object data)
resource "aws_kms_key" "kms_key" {
  tags = {
    ResourceGroup = var.namespace
  }
}

# Encrypt state file with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.kms_key.arn
    }
  }
}