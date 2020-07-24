resource "aws_cloudwatch_event_rule" "automate-cloudwatch-logs-subscription-event" {
  name                = "${var.namespace}-automate-cwl-sub-event"
  description         = "${var.namespace} - Activates lambda to check for new log groups every 15 minutes"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "automate-cloudwatch-logs-subscription-target" {
  target_id = aws_lambda_function.automate-cloudwatch-logs-subscription-lambda.function_name
  rule      = aws_cloudwatch_event_rule.automate-cloudwatch-logs-subscription-event.name
  arn       = aws_lambda_function.automate-cloudwatch-logs-subscription-lambda.arn
}

resource "aws_iam_role" "automate-cloudwatch-logs-subscription-role" {
  name_prefix        = "${var.namespace}-cwl-sub-role"
  assume_role_policy = file("${path.module}/policies/lambda_role.json")
}

resource "aws_iam_role_policy" "automate-cloudwatch-logs-subscription-policy" {
  name_prefix = "${var.namespace}-cwl-sub-policy"
  role        = aws_iam_role.automate-cloudwatch-logs-subscription-role.id
  policy      = templatefile("${path.module}/policies/lambda_policy.tpl", { account_id = var.account_id, region = var.region })
}


resource "aws_lambda_function" "automate-cloudwatch-logs-subscription-lambda" {
  function_name    = "${var.namespace}-cwl-sub-lambda"
  filename         = "./lambda.zip"
  source_code_hash = filebase64sha256("./lambda.zip")
  handler          = "dist/automate-cloudwatch-logs-subscription.handler"

  role        = aws_iam_role.automate-cloudwatch-logs-subscription-role.arn
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