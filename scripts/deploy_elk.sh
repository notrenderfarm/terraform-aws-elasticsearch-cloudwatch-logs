#!/bin/bash

# Exit if any of the intermediate steps fail
set -ex

# Parse deployment variables
eval "$(jq -r '@sh "NAMESPACE=\(.namespace) REGION=\(.region)
  ZONE_COUNT=\(.zone_count) INSTANCE_TYPE=\(.instance_type) ELK_MEMORY=\(.memory)
  API_KEY_SECRET_ID=\(.api_key_secret_id) PASSWORD_SECRET_ID=\(.password_secret_id)"')"

API_KEY=$(aws secretsmanager get-secret-value --secret-id "$API_KEY_SECRET_ID" | jq .SecretString --raw-output)
ELASTIC_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$PASSWORD_SECRET_ID" | jq .SecretString --raw-output)

# Checks if cluster is already deployed
CLUSTER_RESPONSE=$(curl -XGET "https://api.elastic-cloud.com/api/v1/deployments" \
  -H "Authorization: ApiKey $API_KEY")

HAS_DEPLOYED=$(echo $CLUSTER_RESPONSE | jq ".deployments[] | select(.name==\"$NAMESPACE-elk\")")

if [ ! -z "$HAS_DEPLOYED" ] 
  then # Deploy already exists: get Id
  DEPLOYMENT_ID=$(echo $HAS_DEPLOYED | jq --raw-output .id)
  KIBANA_ID=$(echo $HAS_DEPLOYED | jq ".resources[] | select(.kind==\"kibana\") | .id" --raw-output )
else
  # Deploys Elasticsearch + Kibana Cluster
  DEPLOY_RESPONSE=$(curl -X POST "https://api.elastic-cloud.com/api/v1/deployments?validate_only=false" \
    -H "Content-Type: application/json" \
    -H "Authorization: ApiKey $API_KEY" \
    -d "{
    \"resources\": {
      \"elasticsearch\": [
        {
          \"region\": \"gcp-$REGION\",
          \"settings\": {
            \"dedicated_masters_threshold\": 6
          },
          \"plan\": {
            \"cluster_topology\": [
              {
                \"node_type\": {
                  \"data\": true,
                  \"master\": true,
                  \"ingest\": true
                },
                \"instance_configuration_id\": \"$INSTANCE_TYPE\",
                \"zone_count\": $ZONE_COUNT,
                \"size\": {
                  \"resource\": \"memory\",
                  \"value\": $ELK_MEMORY
                },
                \"elasticsearch\": {
                  \"enabled_built_in_plugins\": []
                }
              }
            ],
            \"elasticsearch\": {
              \"version\": \"7.9.3\"
            },
            \"deployment_template\": {
              \"id\": \"gcp-io-optimized\"
            }
          },
          \"ref_id\": \"$NAMESPACE-elasticsearch\"
        }
      ],
      \"enterprise_search\": [],
      \"kibana\": [
        {
          \"elasticsearch_cluster_ref_id\": \"$NAMESPACE-elasticsearch\",
          \"region\": \"gcp-$REGION\",
          \"plan\": {
            \"cluster_topology\": [
              {
                \"instance_configuration_id\": \"gcp.kibana.1\",
                \"zone_count\": 1,
                \"size\": {
                  \"resource\": \"memory\",
                  \"value\": 1024
                }
              }
            ],
            \"kibana\": {
              \"version\": \"7.9.3\"
            }
          },
          \"ref_id\": \"$NAMESPACE-kibana\"
        }
      ]
    },
    \"name\": \"$NAMESPACE-elk\",
    \"metadata\": {
      \"system_owned\": false
    }
  }")

  # Get Id and password
  DEPLOYMENT_ID=$(echo $DEPLOY_RESPONSE | jq --raw-output .id)
  ELASTIC_PASSWORD=$(echo $DEPLOY_RESPONSE | jq --raw-output .resources[0].credentials.password)
  KIBANA_ID=$(echo $DEPLOY_RESPONSE | jq --raw-output ".resources[] | select(.kind==\"kibana\") | .id" )
fi

# Waits for endpoint
unset ELASTICSEARCH_ENDPOINT
while [ -z "$ELASTICSEARCH_ENDPOINT" ] 
do
  STATUS_RESPONSE=$(curl -X GET "https://api.elastic-cloud.com/api/v1/deployments/$DEPLOYMENT_ID/elasticsearch/$NAMESPACE-elasticsearch" \
  -H "Authorization: ApiKey $API_KEY")

  ELASTICSEARCH_ENDPOINT=$(echo $STATUS_RESPONSE | jq --raw-output .info.metadata.endpoint)
  sleep 2s
done

# Updates password  
SECRET_RESPONSE=$(aws secretsmanager put-secret-value --secret-id "$PASSWORD_SECRET_ID" --secret-string "$ELASTIC_PASSWORD")

# Returns endpoints
jq -n --arg endpoint "$ELASTICSEARCH_ENDPOINT" --arg kibana_id "$KIBANA_ID" \
  '{"endpoint":$endpoint, "kibana_id":$kibana_id}'