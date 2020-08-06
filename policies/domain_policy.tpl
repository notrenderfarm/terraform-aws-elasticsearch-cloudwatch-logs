{
  "Statement": [
    {
      "Action":"es:ESHttp*",
      "Effect":"Allow",
      "Principal":{
        "AWS":"arn:aws:iam::${account_id}:role/${cognito_auth_role}"
      },
      "Resource":"arn:aws:es:${region}:${account_id}:domain/${namespace}"
    }
  ],
  "Version":"2012-10-17"
}