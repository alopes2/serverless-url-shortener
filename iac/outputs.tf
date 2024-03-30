output "elasticache_address" {
  description = "Redis Endpoint"
  value       = aws_elasticache_serverless_cache.urls_cache.endpoint[0]
}

output "api_gateway_stage" {
  description = "API Gateway stage"
  value       = aws_api_gateway_stage.live.invoke_url
}
