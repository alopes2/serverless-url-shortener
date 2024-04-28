locals {
  codeIndex = "CodeIndex"
}

resource "aws_dynamodb_table" "urls" {
  name           = "urls"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"
  range_key      = "Code"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "Code"
    type = "S"
  }

  attribute {
    name = "URL"
    type = "S"
  }

  global_secondary_index {
    name            = local.codeIndex
    hash_key        = "Code"
    range_key       = "URL"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }
}

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

  security_group_ids = [data.aws_security_group.default_security_group]
  subnet_ids         = data.aws_subnets.default_vpc.ids
  user_group_id      = aws_elasticache_user_group.main.id
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
  user_ids      = [aws_elasticache_user.main.id]
  engine        = "REDIS"
}
