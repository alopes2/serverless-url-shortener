resource "aws_dax_cluster" "urls" {
  cluster_name       = "urls"
  iam_role_arn       = aws_iam_role.dax.arn
  node_type          = "dax.t2.small"
  replication_factor = 1
  security_group_ids = [data.aws_security_group.default_security_group.id]
  subnet_group_name  = "default"
}

resource "aws_iam_role" "dax" {
  name               = "urls-dax-role"
  assume_role_policy = data.aws_iam_policy_document.assume_dax_role.json
  inline_policy {
    name   = "DefaultPolicy"
    policy = data.aws_iam_policy_document.allow_get_url.json
  }
}

data "aws_iam_policy_document" "assume_dax_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dax.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "allow_get_url" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem"
    ]

    resources = [
      "${aws_dynamodb_table.urls.arn}/index/${local.codeIndex}",
      "${aws_dynamodb_table.urls.arn}",
    ]
  }
}

# Still can't connect lambda to serverless cache
# resource "aws_elasticache_serverless_cache" "urls_cache" {
#   engine = "redis"
#   name   = "urls"
#   cache_usage_limits {
#     data_storage {
#       maximum = 1
#       unit    = "GB"
#     }
#     ecpu_per_second {
#       maximum = 5000
#     }
#   }
#   description          = "URLs cache"
#   major_engine_version = "7"

#   security_group_ids = [data.aws_security_group.default_security_group.id]
#   subnet_ids         = data.aws_subnets.default_vpc.ids
#   user_group_id      = aws_elasticache_user_group.main.user_group_id
# }

# resource "aws_elasticache_user" "main" {
#   user_id       = "url-shortener"
#   user_name     = "url-shortener"
#   access_string = "on ~* +@all"
#   engine        = "REDIS"

#   authentication_mode {
#     type      = "password"
#     passwords = ["MySuperSecret123"]
#   }
# }

# resource "aws_elasticache_user_group" "main" {
#   user_group_id = "main-user-group"
#   user_ids      = [aws_elasticache_user.main.user_id, data.aws_elasticache_user.default.user_id]
#   engine        = "REDIS"
# }

# data "aws_elasticache_user" "default" {
#   user_id = "default"
# }
