resource "aws_elasticsearch_domain" "es" {
  access_policies = templatefile("${path.module}/policies/domain_policy.tpl", {
    namespace       = var.namespace,
    account_id      = var.account_id,
    region          = var.region,
    cognito_es_role = var.cognito_es_role
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
    instance_type            = var.elasticsearch_instance_type
    zone_awareness_enabled   = false
  }

  cognito_options {
    enabled          = true
    identity_pool_id = "${var.region}:${var.cognito_identity_pool_id}"
    role_arn         = "arn:aws:iam::${var.account_id}:role/${var.cognito_es_role}"
    user_pool_id     = var.cognito_user_pool_id
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    iops        = 0
    volume_size = var.elasticsearch_volume_size
    volume_type = "gp2"
  }
}