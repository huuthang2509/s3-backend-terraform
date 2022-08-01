provider "aws" {
  region = var.region
}

module "s3_backend" {
  source = "./s3-backend"

  region            = var.region
  namespace         = var.namespace
  iam_policies_json = var.iam_policies_json
}

output "s3_backend_config" {
  value = module.s3_backend
}