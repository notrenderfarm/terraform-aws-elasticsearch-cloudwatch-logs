resource "aws_cloudwatch_event_rule" "automate-cloudwatch-logs-subscription-event" {
  name                = "${var.namespace}-automate-cwl-sub-event"
  description         = "${var.namespace} - Activates lambda to check for new log groups every ${var.automate_subscription_rate}"
  schedule_expression = "rate(${var.automate_subscription_rate})"
}

resource "aws_cloudwatch_event_target" "automate-cloudwatch-logs-subscription-target" {
  target_id = aws_lambda_function.automate-cloudwatch-logs-subscription-lambda.function_name
  rule      = aws_cloudwatch_event_rule.automate-cloudwatch-logs-subscription-event.name
  arn       = aws_lambda_function.automate-cloudwatch-logs-subscription-lambda.arn
}

resource "aws_lambda_function" "automate-cloudwatch-logs-subscription-lambda" {
  function_name    = "${var.namespace}-cwl-sub-lambda"
  filename         = "./lambda.zip"
  source_code_hash = filebase64sha256("./lambda.zip")
  handler          = "dist/automate-cloudwatch-logs-subscription.handler"

  role        = aws_iam_role.lambda-role.arn
  memory_size = "128"
  runtime     = "nodejs12.x"
  timeout     = 900

  environment {
    variables = {
      CLOUDWATCH_LOGS_PREFIXES = join(",", var.cloudwatch_logs_prefixes)
      LAMBDA_ARN               = aws_lambda_function.cloudwatch-logs-to-elasticsearch-lambda.arn
    }
  }
}