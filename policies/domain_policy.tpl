{
  "Statement": [
    {
      "Action":"es:ESHttp*",
      "Effect":"Allow",
      "Principal":{
        "AWS":"arn:aws:iam::${account_id}:role/Cognito_ElasticSearch_Auth_Role"
      },
      "Resource":"arn:aws:es:${region}:${account_id}:domain/${es_domain}"
    }
  ],
  "Version":"2012-10-17"
}