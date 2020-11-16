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
    region             = var.gcp_options.region
    zone_count         = var.elasticsearch_instance_count
    instance_type      = var.gcp_options.elasticsearch_instance_type
    memory             = var.gcp_options.elasticsearch_memory_size
    api_key_secret_id  = data.aws_secretsmanager_secret.api_secret.id
    password_secret_id = data.aws_secretsmanager_secret.password_secret.id
  }
}

locals {
  elasticsearch_endpoint = var.cloud == "GCP" ? "https://${data.external.elasticsearch.result.endpoint}" : aws_elasticsearch_domain.elasticsearch.endpoint
  kibana_endpoint        = var.cloud == "GCP" ? "https://${data.external.elasticsearch.result.kibana_id}.${var.region}.gcp.elastic-cloud.com" : aws_elasticsearch_domain.elasticsearch.kibana_endpoint
  elasticsearch_password = var.cloud == "GCP" ? data.aws_secretsmanager_secret_version.password_secret_version.secret_string : ""
}

data "aws_secretsmanager_secret_version" "password_secret_version" {
  secret_id = data.aws_secretsmanager_secret.password_secret.id
}

resource "aws_elasticsearch_domain" "elasticsearch" {
  count = var.cloud == "AWS" ? 1 : 0
  access_policies = templatefile("${path.module}/policies/domain_policy.tpl", {
    namespace         = var.namespace,
    account_id        = var.account_id,
    region            = var.region,
    cognito_auth_role = var.aws_options.cognito_es_role
  })
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  domain_name           = var.namespace
  elasticsearch_version = "7.1"

  tags = {
    "Domain" = var.namespace
  }

  cluster_config {
    dedicated_master_count   = 0
    dedicated_master_enabled = false
    instance_count           = var.elasticsearch_instance_count
    instance_type            = var.aws_options.elasticsearch_instance_type
    zone_awareness_enabled   = false
  }

  cognito_options {
    enabled          = true
    identity_pool_id = "${var.region}:${var.aws_options.cognito_identity_pool_id}"
    role_arn         = "arn:aws:iam::${var.aws_options.account_id}:role/${var.aws_options.cognito_es_role}"
    user_pool_id     = var.aws_options.cognito_user_pool_id
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    iops        = 0
    volume_size = var.aws_options.elasticsearch_volume_size
    volume_type = "gp2"
  }
}

