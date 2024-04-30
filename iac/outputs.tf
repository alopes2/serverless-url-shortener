output "api_gateway_stage" {
  description = "API Gateway stage"
  value       = aws_api_gateway_stage.live.invoke_url
}

output "dax_endpoint" {
  description = "DAX Endpoint"
  value       = aws_dax_cluster.urls.configuration_endpoint
}
