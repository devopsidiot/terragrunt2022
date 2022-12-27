locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "git@github.com:devopsidiot/terraform-modules.git//terraform-infrastructure-app"
}

dependency "eks" {
  config_path = "../../eks"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  create_role = true
  create_ecr  = true

  shared_rds_access = {
    "rds_cluster_name"    = "${local.common_vars["environment"]}-shared-rds"
    "rds_cluster_account" = "${local.common_vars["aws_account_id"]}"
    "rds_cluster_region"  = "${local.common_vars["aws_region"]}"
    "rds_user_name"       = "${basename(get_terragrunt_dir())}_ro"
  }

  service_name = "${basename(get_terragrunt_dir())}"

  eks_cluster_attributes = dependency.eks.outputs

  # NewRelic Alerting

  new_relic_alerts = {
    newrelic_alert_policy                     = "${basename(get_terragrunt_dir())}-qa-us",
    newrelic_alert_policy_incident_preference = "PER_CONDITION",
    newrelic_slack_channel_name               = "devopsidiot-services-env-alerts",

    newrelic_alert_conditions = {
      "AUTH0_ERROR" = {
        violation_time_limit_seconds = 2592000
        aggregation_method           = "event_timer"
        aggregation_timer            = 60
        nrql = {
          "query" = {
            query = "SELECT count(*) FROM Log where container_name = '${basename(get_terragrunt_dir())}' AND level = 'error' AND message LIKE '%us.auth0.com%'"
          }
        },
        critical = {
          "critical" = {
            operator              = "above"
            threshold             = 0
            threshold_duration    = 120
            threshold_occurrences = "at_least_once"
          }
        }
      },
      "SHOPIFY_ERROR" = {
        violation_time_limit_seconds = 2592000
        aggregation_method           = "event_timer"
        aggregation_timer            = 60
        nrql = {
          "query" = {
            query = "SELECT count(*) FROM Log where container_name = '${basename(get_terragrunt_dir())}' AND level = 'error' AND message LIKE '%myshopify.com%' AND message NOT LIKE '%UNIDENTIFIED_CUSTOMER%' AND message NOT LIKE '%email%has%' AND message NOT LIKE '%Login%attempt%limit%exceeded%'"
          }
        },
        critical = {
          "critical" = {
            operator              = "above"
            threshold             = 0
            threshold_duration    = 120
            threshold_occurrences = "at_least_once"
          }
        }
      },
      "AUTH_API_ERROR" = {
        violation_time_limit_seconds = 2592000
        aggregation_method           = "event_timer"
        aggregation_timer            = 60
        nrql = {
          "query" = {
            query = "SELECT count(*) FROM Log where container_name = '${basename(get_terragrunt_dir())}' AND level = 'error' AND message NOT LIKE '%us.auth0.com%' AND message NOT LIKE '%myshopify.com%' AND message NOT LIKE '%UNIDENTIFIED_CUSTOMER%' AND message NOT LIKE '%email%has%' AND message NOT LIKE '%Login%attempt%limit%exceeded%'"
          }
        },
        critical = {
          "critical" = {
            operator              = "above"
            threshold             = 0
            threshold_duration    = 120
            threshold_occurrences = "at_least_once"
          }
        }
      },
    }
  }
}

include {
  path = find_in_parent_folders()
}
