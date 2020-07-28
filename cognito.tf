resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.namespace}_users_pool"
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  schema {
    attribute_data_type = "String"
    name = "email"
    required = true
  }
  alias_attributes = ["email"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.namespace
  user_pool_id = aws_cognito_user_pool.user_pool.id
}


resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = replace("${var.namespace}_identity_pool", "-", "_")
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = "${aws_cognito_identity_pool.identity_pool.id}"

  roles = {
    authenticated   = "${aws_iam_role.auth_iam_role.arn}"
    unauthenticated   = "${aws_iam_role.unauth_iam_role.arn}"
  }
}

resource "aws_iam_role" "auth_iam_role" {
  name = "Cognito_terraform-test_elkAuth_Role"
  assume_role_policy = templatefile("${path.module}/policies/auth_cognito_role.tpl", 
    { pool_id = aws_cognito_user_pool.user_pool.id})
}


resource "aws_iam_role_policy" "web_iam_auth_role_policy" {
  name = "web_iam_auth_role_policy"
  role = "${aws_iam_role.auth_iam_role.id}"
  policy = file("${path.module}/policies/auth_cognito_policy.json")
}

resource "aws_iam_role" "unauth_iam_role" {
  name = "Cognito_terraform-test_elkUnAuth_Role"
  assume_role_policy = templatefile("${path.module}/policies/unauth_cognito_role.tpl", 
    { pool_id = aws_cognito_user_pool.user_pool.id})
}


resource "aws_iam_role_policy" "web_iam_unauth_role_policy" {
  name = "web_iam_unauth_role_policy"
  role = "${aws_iam_role.unauth_iam_role.id}"
  policy = file("${path.module}/policies/unauth_cognito_policy.json")
}

resource "aws_iam_role" "cognito-role" {
  name = var.cognito_es_role
  assume_role_policy = file("${path.module}/policies/es_role.json")
}

resource "aws_iam_policy" "cognito-policy" {
  name_prefix        = "${var.cognito_es_role}-cognito-policy"
  policy = file("${path.module}/policies/es_cognito_policy.json")
}

resource "aws_iam_role_policy_attachment" "cognito-attach" {
  role       = aws_iam_role.cognito-role.name
  policy_arn = aws_iam_policy.cognito-policy.arn
}