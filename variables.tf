variable "region" {
  type = string
}

variable "namespace" {
  description = "The project namespace to use for resource naming"
  type = string
}

variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  type = list(string)
  default = null
}

variable "iam_policies_json" {
  description = "List of policies should be used"
  type = list(string)
}