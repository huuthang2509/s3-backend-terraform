
# Current AWS accout
data "aws_caller_identity" "current" {}

# If no principal ARNs are specified, use the current account
locals {
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]

  # Merge Policy
  iam_policies = [for policy_json in var.iam_policies_json : jsondecode(file("${path.module}/policies/${policy_json}"))]

  # List of Statements
  iam_policy_statements = flatten([
    for policy in local.iam_policies : policy.Statement
  ])

  # Merge into 1 policy_document
  iam_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = local.iam_policy_statements
  })
}

# Create policy
resource "aws_iam_policy" "iam_policy" {
  name = "${var.namespace}-tf-policy"
  policy = local.iam_policy_document
}

# Create role
resource "aws_iam_role" "iam_role" {
  name = "${var.namespace}-tf-assume-role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": ${jsonencode(local.principal_arns)}
        },
        "Effect": "Allow"
      }
    ]
  }
  EOF

  tags = {
    ResourceGroup = var.namespace
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}



# # Policy doc
# data "aws_iam_policy_document" "policy_doc" {

#   # List all bucket
#   statement {
#     actions   = ["s3:ListBucket", "s3:GetBucketVersioning"]
#     resources = [aws_s3_bucket.s3_bucket.arn]
#   }

#   # For each bucket: get, put, del
#   statement {
#     actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#     resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
#   }

#   # Dynamodb
#   statement {
#     actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
#     resources = [aws_dynamodb_table.dynamodb_table.arn]
#   }
# }

# Output
# policy_doc_json = data.aws_iam_policy_document.policy_doc.json

# # Create policy
# resource "aws_iam_policy" "iam_policy" {
#   name = "${var.namespace}-tf-policy"
#   path = "/"
#   policy = data.aws_iam_policy_document.policy_doc.json
# }