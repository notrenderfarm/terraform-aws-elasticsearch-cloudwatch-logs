resource "aws_elasticsearch_domain" "es" {
  access_policies = templatefile("${path.module}/policies/domain_policy.tpl", {
    es_domain  = var.es_domain,
    account_id = var.account_id
    region     = var.region
  })
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  domain_name           = var.es_domain
  elasticsearch_version = "7.1"

  tags = {
    "Domain" = var.es_domain
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
    role_arn         = "arn:aws:iam::${var.account_id}:role/service-role/CognitoAccessForAmazonES"
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