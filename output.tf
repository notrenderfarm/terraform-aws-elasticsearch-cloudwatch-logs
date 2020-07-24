output "kibana_endpoint" {
  value = aws_elasticsearch_domain.es.kibana_endpoint
}

output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.es.endpoint
}
