# terraform-aws-elasticsearch-cloudwatch-logs
Terraform module to provision an AWS ElasticSearch service with automatic subscription of CloudWatch logs

### Status

Work in progress

### Usage

```terraform
module "elasticsearch_cloudwatch_logs" {
  source = "github.com/notrenderfarm/terraform-aws-elasticsearch-cloudwatch-logs"

  region = "us-east-1"
  account_id = "12345678900"
  namespace = "notrenderfarm"

  cognito_identity_pool_id = "00000000-0000-0000-0000-000000000000"
  cognito_user_pool_id = "us-east-1_abcdefghi"
  cognito_es_role = "Cognito_notrenderfarm_Role"

  cloudwatch_logs_prefixes = [
    "/aws/lambda/notrenderfarm-api", 
    "/aws/lambda/notrenderfarm-monitor"
  ]
}

output "kibana_endpoint" {
  value = module.elasticsearch_cloudwatch_logs.kibana_endpoint
}
```

### Input

| Parameter | Description | Type | Default | 
| --------- | ----------- | ---- | ------- | 
| region    | AWS region | `string` |
| account_id    | AWS Account Id | `string` |  |
| namespace    | Namespace of this service | `string` |  |
| cognito_identity_pool_id    | Cognito Identity Pool Id | `string` |  |
| cognito_user_pool_id    | Cognito User Pool Id | `string` |  |
| cloudwatch_logs_prefixes    | CloudWatch Logs prefixes to automatically subscribe to ElasticSearch | `string` |  |
| elasticsearch_instance_count    | Number of ElasticSearch instances | `number` | `1` |
| elasticsearch_instance_type    | Type of ElasticSearch instances | `string` | `"t2.medium.elasticsearch"` |
| elasticsearch_volume_size    | Volume size of ElasticSearch disk | `number` | `35` |
| automate_subscription_rate    | Rate of the automatic subscription lambda | `string` | `15 minutes` |

### Output

| Parameter | Description | Type |  
| --------- | ----------- | ---- |  
| kibana_endpoint    | Kibana endpoint | `string` | 
| elasticsearch_endpoint    | ElasticSearch endpoint | `string` |  

### Deploy

```bash
terraform init
( cd .terraform/modules/elasticsearch_cloudwatch_logs/ && make build )
terraform apply
```