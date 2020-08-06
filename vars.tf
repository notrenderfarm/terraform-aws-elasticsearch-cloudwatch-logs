variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "cloudwatch_logs_prefixes" {
  type = list(string)
}

variable "cognito_identity_pool_id" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_es_role" {
  type    = string
  default = "service-role/CognitoAccessForAmazonES"
}

variable "cognito_auth_role" {
  type = string
}

variable "elasticsearch_instance_type" {
  type    = string
  default = "t2.medium.elasticsearch"
}

variable "elasticsearch_volume_size" {
  type    = number
  default = 35
}

variable "elasticsearch_instance_count" {
  type    = number
  default = 1
}

variable "automate_subscription_rate" {
  type    = string
  default = "15 minutes"
}
