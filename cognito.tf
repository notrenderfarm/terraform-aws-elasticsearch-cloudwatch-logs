locals {
  cognito_es_role     = "Cognito_${var.namespace}_role"
  cognito_auth_role   = "Cognito_${var.namespace}_Auth_role"
  cognito_unauth_role = "Cognito_${var.namespace}_Unauth_role"
}

resource "aws_cognito_user_pool" "user-pool" {
  name = "${var.namespace}_user_pool"
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.namespace
  user_pool_id = aws_cognito_user_pool.user-pool.id
}


resource "aws_cognito_identity_pool" "identity-pool" {
  identity_pool_name               = replace("${var.namespace}_identity_pool", "-", "_")
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "pool-roles-attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity-pool.id

  roles = {
    authenticated   = aws_iam_role.auth-iam-role.arn
    unauthenticated = aws_iam_role.unauth-iam-role.arn
  }
}

resource "aws_iam_role" "auth-iam-role" {
  name = local.cognito_auth_role
  assume_role_policy = templatefile("${path.module}/policies/auth_cognito_role.tpl",
  { pool_id = aws_cognito_user_pool.user-pool.id })
}


resource "aws_iam_role_policy" "iam-auth-role-policy" {
  name   = "${local.cognito_auth_role}_role_policy"
  role   = aws_iam_role.auth-iam-role.id
  policy = file("${path.module}/policies/auth_cognito_policy.json")
}

resource "aws_iam_role" "unauth-iam-role" {
  name = local.cognito_unauth_role
  assume_role_policy = templatefile("${path.module}/policies/unauth_cognito_role.tpl",
  { pool_id = aws_cognito_user_pool.user-pool.id })
}


resource "aws_iam_role_policy" "web_iam_unauth_role_policy" {
  name   = local.cognito_unauth_role
  role   = aws_iam_role.unauth-iam-role.id
  policy = file("${path.module}/policies/unauth_cognito_policy.json")
}

resource "aws_iam_role" "cognito-role" {
  name               = local.cognito_es_role
  assume_role_policy = file("${path.module}/policies/es_role.json")
}

resource "aws_iam_policy" "cognito-policy" {
  name   = "${var.namespace}-cognito-policy"
  policy = file("${path.module}/policies/es_cognito_policy.json")
}

resource "aws_iam_role_policy_attachment" "cognito-attach" {
  role       = aws_iam_role.cognito-role.name
  policy_arn = aws_iam_policy.cognito-policy.arn
}