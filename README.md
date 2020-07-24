# terraform-aws-elasticsearch-lambdas
Terraform module to provision an AWS ElasticSearch service with automatic subscription of CloudWatch logs

### Usage

```js
module "elasticsearch_lambdas" {
  region = "us-east-1"
  account_id = "12345678900"
  namespace = "notrenderfarm"

  elasticsearch_instance_count = 1
  elasticsearch_instance_type = "t2.medium.elasticsearch"
  elasticsearch_volume_size = 35

  cognito_identity_pool_id = "0000..."
  cognito_user_pool_id = "0000..."

  cloudwatch_logs_prefixes = [
    "/aws/lambda/notrenderfarm-api", 
    "/aws/lambda/notrenderfarm-monitor"
  ]
}
```