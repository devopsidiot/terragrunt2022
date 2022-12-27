terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//vpc"
}
inputs = {

  vpc_name = "devopsidiot-vpc"
  vpc_cidr = "10.4.0.0/16"

  vpc_azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
include {
  path = find_in_parent_folders()
}
