locals {
  aws_defaults = {
    cognito_es_role             = "service-role/CognitoAccessForAmazonES"
    elasticsearch_volume_size   = 35
    elasticsearch_instance_type = "t2.medium.elasticsearch"
  }
  aws_options = merge(local.aws_defaults, var.aws_options)
}

resource "aws_elasticsearch_domain" "elasticsearch" {
  count = var.cloud == "AWS" ? 1 : 0
  access_policies = templatefile("${path.module}/policies/domain_policy.tpl", {
    namespace         = var.namespace,
    account_id        = var.account_id,
    region            = var.region,
    cognito_auth_role = local.aws_options.cognito_es_role
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
    instance_type            = local.aws_options.elasticsearch_instance_type
    zone_awareness_enabled   = false
  }

  cognito_options {
    enabled          = true
    identity_pool_id = "${var.region}:${local.aws_options.cognito_identity_pool_id}"
    role_arn         = "arn:aws:iam::${var.account_id}:role/${local.aws_options.cognito_es_role}"
    user_pool_id     = local.aws_options.cognito_user_pool_id
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    iops        = 0
    volume_size = local.aws_options.elasticsearch_volume_size
    volume_type = "gp2"
  }
}
