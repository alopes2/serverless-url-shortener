
resource "aws_elasticache_serverless_cache" "urls_cache" {
  engine = "redis"
  name   = "urls"
  cache_usage_limits {
    data_storage {
      maximum = 1
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  description          = "URLs cache"
  major_engine_version = "7"

  security_group_ids = [data.aws_security_group.default_security_group.id]
  subnet_ids         = data.aws_subnets.default_vpc.ids
  user_group_id      = aws_elasticache_user_group.main.user_group_id
}

resource "aws_elasticache_user" "main" {
  user_id       = "urlShortener"
  user_name     = "urlShortener"
  access_string = "on ~* +@all"
  engine        = "REDIS"

  authentication_mode {
    type = "iam"
  }
}

resource "aws_elasticache_user_group" "main" {
  user_group_id = "mainUserGroup"
  user_ids      = [aws_elasticache_user.main.user_id, data.aws_elasticache_user.default.user_id]
  engine        = "REDIS"
}

data "aws_elasticache_user" "default" {
  user_id = "default"
}
