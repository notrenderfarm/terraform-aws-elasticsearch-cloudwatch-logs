resource "aws_iam_role" "lambda-role" {
  name_prefix        = "${var.namespace}-lambda-role"
  assume_role_policy = file("${path.module}/policies/lambda_role.json")
}

resource "aws_iam_role_policy" "lambda-policy" {
  name_prefix = "${var.namespace}-lambda-policy"
  role        = aws_iam_role.lambda-role.id
  policy = templatefile("${path.module}/policies/lambda_policy.tpl", {
    account_id = var.account_id,
    region     = var.region
  })
}
