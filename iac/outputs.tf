output "elasticache_address" {
  description = "Redis Endpoint"
  value       = aws_elasticache_serverless_cache.urls_cache.endpoint
}
