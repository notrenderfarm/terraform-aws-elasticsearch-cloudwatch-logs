locals {
  gcp_defaults = {
    region                      = "us-east4"
    elasticsearch_instance_type = "gcp.data.highio.1"
    elasticsearch_memory_size   = 8192
  }

  gcp_options = merge(local.gcp_defaults, var.gcp_options)
}


data "aws_secretsmanager_secret" "api_secret" {
  name = "${var.namespace}-elasticsearch-api-key"
}

data "aws_secretsmanager_secret" "password_secret" {
  name = "${var.namespace}-elasticsearch-password"
}

data "external" "elasticsearch" {
  count   = var.cloud == "GCP" ? 1 : 0
  program = ["bash", "-c", "${path.module}/scripts/deploy_elk.sh"]

  query = {
    namespace          = var.namespace
    region             = local.gcp_options.region
    zone_count         = var.elasticsearch_instance_count
    instance_type      = local.gcp_options.elasticsearch_instance_type
    memory             = local.gcp_options.elasticsearch_memory_size
    api_key_secret_id  = data.aws_secretsmanager_secret.api_secret.id
    password_secret_id = data.aws_secretsmanager_secret.password_secret.id
  }
}

data "aws_secretsmanager_secret_version" "password_secret_version" {
  secret_id = data.aws_secretsmanager_secret.password_secret.id
}
