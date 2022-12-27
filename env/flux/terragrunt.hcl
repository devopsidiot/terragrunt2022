locals {
  params = yamldecode(sops_decrypt_file(find_in_parent_folders("shared-parameters.sops.yaml")))
}
terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//flux"
}
dependency "eks" {
  config_path = "../eks"
}
inputs = {
  target_path                        = "clusters/americas/qa/us"
  cluster_name                       = dependency.eks.outputs.cluster_id
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_admin_role                 = dependency.eks.outputs.cluster_admin_role
  flux_version                       = "v0.30.1"
  flux_token                         = local.params.github_pat
}
include {
  path = find_in_parent_folders()
}