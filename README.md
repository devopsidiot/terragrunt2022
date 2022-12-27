# Terragrunt2022 repo

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)

## About <a name = "about"></a>

The terraform-live repo describes the live state of terraform per environment, per module.  This is enabled using the terragrunt wrapper for terraform.  

## Getting Started <a name = "getting_started"></a>

- [Terragrunt Install Page](https://terragrunt.gruntwork.io/docs/getting-started/install/)

### Prerequisites

- You will need the ability to assume the admin role in the AWS account(s) you want to work with.

### Installing

- Before applying changes you will need to init each working directory you want to work from.  This works the same way it did with terraform, but the command is terragrunt.

```shell
cd qa/eks
terragrunt init
.
.
terragrunt plan
```

## Usage <a name = "usage"></a>

- To apply changes cd into the directory that represents the module / environment you want to deploy to and run terragrunt apply.

```shell
cd qa/eks
terragrunt apply
```

- If the source of a module does not point to a tag or a ref you may need to clear cache.  [Terragrunt Cache Docs](https://terragrunt.gruntwork.io/docs/features/caching/#clearing-the-terragrunt-cache)
- Instead of using inputs, terragrunt defines them in terragrunt.hcl files that live within the folders in terraform-live.  [Terragrunt inputs Docs](https://terragrunt.gruntwork.io/docs/features/inputs/)
- It is possible to do rapid local development using terragrunt using the --terragrunt-source flag.  [Terragrunt - Working Locally](https://terragrunt.gruntwork.io/docs/features/keep-your-terraform-code-dry/#working-locally)  *Pay attention to the important gotchas if you go with this route!*
