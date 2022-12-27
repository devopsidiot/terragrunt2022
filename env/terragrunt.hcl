locals {
  params = yamldecode(sops_decrypt_file(find_in_parent_folders("shared-parameters.sops.yaml")))
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::123456789101:role/admin"
  }
  forbidden_account_ids = [
    "1019877654321" #no standard terraform modules run against the root account
  ]
  ignore_tags {
    key_prefixes = [
      "kubernetes.io/",
      "AutoTag"
      ]
  }
  version = "~> 3.0"
}

provider "newrelic" {
  account_id = 1234567
  region     = "US"
  ## api_key must be of type "user". Set with NEW_RELIC_API_KEY env variable ##
  api_key = "${local.params.newrelic_api-key}"
}

EOF
}

generate "tf-version" {
  path      = "tf-version.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = "1.0.0"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "devopsidiot-env-tf"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-infra"
    role_arn       = "arn:aws:iam::123456789101:role/admin"
  }
}

generate "env_file" {
  path      = "env.tf"
  if_exists = "overwrite"
  contents  = <<EOF
variable "environment" {
  type = string
  default = "env"
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "account_id" {
  type = string
  default = "123456789101"
}
EOF
}