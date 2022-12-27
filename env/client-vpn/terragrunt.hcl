terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//client-vpn"
}
dependency "vpc" {
  config_path = "../vpc"
}
retryable_errors = [
  "(?s).*error creating client VPN route.*InvalidClientVpnActiveAssociationNotFound.*",
  "(?s).*ssh_exchange_identification.*Connection closed by remote host.*",
  "(?s).*Error installing provider.*tcp.*connection reset by peer.*"
]
inputs = {

  client_cidr     = "10.254.0.0/22"
  name            = "env"
  home_dir        = get_env("HOME", ".")
  private_subnets = dependency.vpc.outputs.private_subnets
  vpc_cidr        = dependency.vpc.outputs.vpc_cidr
  default_sg_id   = dependency.vpc.outputs.default_sg_id
}

include {
  path = find_in_parent_folders()
}
