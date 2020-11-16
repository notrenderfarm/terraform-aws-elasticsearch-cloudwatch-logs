variable "namespace" {
  type = string
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "automate_subscription_rate" {
  type    = string
  default = "15 minutes"
}

variable "cloudwatch_logs_prefixes" {
  type = list(string)
}

variable "cloud" {
  type = string
}

variable "aws_options" {
  default = {
    cognito_identity_pool_id    = ""
    cognito_user_pool_id        = ""
    cognito_es_role             = "service-role/CognitoAccessForAmazonES"
    cognito_auth_role           = ""
    elasticsearch_volume_size   = 35
    elasticsearch_instance_type = "t2.medium.elasticsearch"
  }
}

variable "gcp_options" {
  default = {
    project_id                  = ""
    region                      = "us-east4"
    elasticsearch_instance_type = "gcp.data.highio.1"
    elasticsearch_memory_size   = 8192
  }
}

variable "elasticsearch_instance_count" {
  type    = number
  default = 1
}
