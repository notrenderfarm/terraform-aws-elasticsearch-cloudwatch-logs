variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "es_domain" {
  type = string
}

variable "elasticsearch_instance_type" {
  type = string
}

variable "elasticsearch_volume_size" {
  type = number
}

variable "elasticsearch_instance_count" {
  type = number
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