# terraform-aws-elasticsearch-cloudwatch-logs

Terraform module to provision an AWS Elasticsearch Service with automatic subscription of CloudWatch Logs

![Terraform Validation](https://github.com/notrenderfarm/terraform-aws-elasticsearch-cloudwatch-logs/workflows/Terraform%20Validation/badge.svg) 


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
| cognito_es_role    | IAM Role used by ElasticSearch to create Cognito Client and credentials | `string` | `service-role/CognitoAccessForAmazonES` |
| cloudwatch_logs_prefixes    | CloudWatch Logs prefixes to automatically subscribe to ElasticSearch | `string` |  |
| elasticsearch_instance_count    | Number of Elasticsearch instances | `number` | `1` |
| elasticsearch_instance_type    | Type of Elasticsearch instances | `string` | `"t2.medium.elasticsearch"` |
| elasticsearch_volume_size    | Volume size of Elasticsearch disk | `number` | `35` |
| automate_subscription_rate    | Rate of the automatic subscription lambda | `string` | `15 minutes` |

### Output

| Parameter | Description | Type |  
| --------- | ----------- | ---- |  
| kibana_endpoint    | Kibana endpoint | `string` | 
| elasticsearch_endpoint    | Elasticsearch endpoint | `string` |  

### Deploy

```bash
terraform init
( cd .terraform/modules/elasticsearch_cloudwatch_logs/ && make build )
terraform apply
```
### Notes on Cognito Authentication for Kibana
It is currently impossible to provision a `cognito_identity_pool` and `cognito_user_pool` to be used for authenticating Kibana with AWS ElasticSearch using only terraform (see [Issue #5557](https://github.com/terraform-providers/terraform-provider-aws/issues/5557)). This repository will be updated as soon as this feature becomes supported.

Meanwhile, it is necessary to create those resources manually on the AWS Console. There is a great step-by-step guide on the [AWS documentation](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-cognito-auth.html#es-cognito-auth-identity-providers) detailing how to do just that.

As for the `cognito_es_role` argument, the default `CognitoAccessForAmazonES` should have all the permissions necessary, but if you decide to use your own role, attach the `AmazonESCognitoAccess` policy to the role and it should work as expected.
