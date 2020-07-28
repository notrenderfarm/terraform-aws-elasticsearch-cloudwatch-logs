{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CopiedFromTemplateAWSLambdaVPCAccessExecutionRole1",
      "Effect": "Allow",
      "Action": [
        "logs:Create*",
        "logs:Describe*",
        "es:ESHttpPost"
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
    },
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:${region}:${account_id}:function:${function_name}",
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:events:${region}:${account_id}:rule/${event_name}"
        }
      }
    }
  ]
}