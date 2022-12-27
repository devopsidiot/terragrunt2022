terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//eks"
}
dependency "vpc" {
  config_path = "../vpc"
}
dependencies {
  paths = ["../client-vpn"]
}
inputs = {
    secrets = {
    argo     = "arn:aws:ssm:us-east-1:123456789101:parameter/argocd/*",
    sre      = "arn:aws:ssm:us-east-1:123456789101:parameter/sre/*",
    newrelic = "arn:aws:ssm:us-east-1:123456789101:parameter/newrelic/*",
    vendor   = "arn:aws:ssm:us-east-1:123456789101:parameter/vendor/*",
    infra    = "arn:aws:ssm:us-east-1:123456789101:parameter/infra/*"
  }

  kms_alias                         = "alias/parameter_store_key"
  kubeconfig_role                   = "arn:aws:iam::123456789101:role/admin"
  cluster_name                      = "devopsidiot-eks"
  private_subnets                   = dependency.vpc.outputs.private_subnets
  vpc_cidr                          = dependency.vpc.outputs.vpc_cidr
  default_sg_id                     = dependency.vpc.outputs.default_sg_id
  public_subnets                    = dependency.vpc.outputs.public_subnets
  vpc_id                            = dependency.vpc.outputs.vpc_id
  home_dir                          = get_env("HOME", ".")
  eks_cluster_version               = "1.22"
  sops_file                         = "${get_terragrunt_dir()}/../.sops.yaml"
  decrypt_script                    = "${get_terragrunt_dir()}/../decrypt"
  encrypt_script                    = "${get_terragrunt_dir()}/../encrypt"
  shared_parameters_yaml            = "${get_terragrunt_dir()}/../shared-parameters.decrypted.yaml"
  gitignore                         = "${get_terragrunt_dir()}/../.gitignore"
  use_spot_karpenter                = true
}
include {
  path = find_in_parent_folders()
}