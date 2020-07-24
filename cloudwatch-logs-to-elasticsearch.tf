resource "aws_iam_role" "cloudwatch-logs-to-elasticsearch-role" {
  name_prefix        = "${var.namespace}-cwl-to-es-role"
  assume_role_policy = file("${path.module}/policies/lambda_role.json")
}

resource "aws_lambda_permission" "cloudwatch-logs-to-elasticsearch-permission" {
  statement_id  = "${var.namespace}-cwl-to-es-permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch-logs-to-elasticsearch-lambda.arn
  principal     = "logs.${var.region}.amazonaws.com"
}

resource "aws_lambda_function" "cloudwatch-logs-to-elasticsearch-lambda" {
  function_name    = "${var.namespace}-cwl-to-es-lambda"
  filename         = "./lambda.zip"
  source_code_hash = filebase64sha256("./lambda.zip")
  handler          = "cloudwatch-logs-to-elasticsearch.handler"

  role        = aws_iam_role.cloudwatch-logs-to-elasticsearch-role.arn
  memory_size = "128"
  runtime     = "nodejs12.x"
  timeout     = 900

  environment {
    variables = {
      es_endpoint = aws_elasticsearch_domain.es.endpoint
    }
  }
}
