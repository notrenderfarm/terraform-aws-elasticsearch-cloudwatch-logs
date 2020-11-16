provider "aws" {
  region = var.region
}

provider "google" {
  project = var.gcp_options.project_id
}

locals {
  elasticsearch_endpoint = var.cloud == "GCP" ? "https://${data.external.elasticsearch[0].result.endpoint}" : aws_elasticsearch_domain.elasticsearch[0].endpoint
  kibana_endpoint        = var.cloud == "GCP" ? "https://${data.external.elasticsearch[0].result.kibana_id}.${var.gcp_options.region}.gcp.elastic-cloud.com" : aws_elasticsearch_domain.elasticsearch[0].kibana_endpoint
  elasticsearch_password = var.cloud == "GCP" ? data.aws_secretsmanager_secret_version.password_secret_version.secret_string : ""
}
