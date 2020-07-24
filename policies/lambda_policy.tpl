{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CopiedFromTemplateAWSLambdaVPCAccessExecutionRole1",
      "Effect": "Allow",
      "Action": [
        "logs:Create*",
        "logs:Describe*",
        "ecs:listTasks",
        "es:ESHttpPost",
        "sqs:SendMessage"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CopiedFromTemplateAWSLambdaBasicExecutionRole2",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:Put*",
        "logs:FilterLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${region}:${account_id}:log-group:*"
      ]
    }
  ]
}