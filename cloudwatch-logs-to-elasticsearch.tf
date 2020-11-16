resource "aws_lambda_permission" "cloudwatch-logs-to-elasticsearch-permission" {
  statement_id  = "${var.namespace}-cwl-to-es-permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch-logs-to-elasticsearch-lambda.arn
  principal     = "logs.${var.region}.amazonaws.com"
}

resource "aws_lambda_function" "cloudwatch-logs-to-elasticsearch-lambda" {
  function_name    = "${var.namespace}-cwl-to-es-lambda"
  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  handler          = "cloudwatch-logs-to-elasticsearch.handler"

  role        = aws_iam_role.lambda-role.arn
  memory_size = "128"
  runtime     = "nodejs12.x"
  timeout     = 900

  environment {
    variables = {
      ELASTICSEARCH_ENDPOINT = local.elasticsearch_endpoint
      ELASTIC_PASSWORD       = var.cloud == "GCP" ? local.elastic_password : ""
    }
  }
}
