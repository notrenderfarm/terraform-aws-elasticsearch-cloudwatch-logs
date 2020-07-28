variable "namespace" {
  type    = string
  default = "terraform-test"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type    = string
  default = "715293289758"
}

variable "cloudwatch_logs_prefixes" {
  type = list(string)
  default = [
    "/aws/lambda/notrenderfarm-api",
    "/aws/lambda/notrenderfarm-monitor"
  ]
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
