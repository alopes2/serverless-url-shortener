data "aws_iam_policy_document" "create_short_url_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
    ]

    resources = [
      aws_dynamodb_table.urls.arn
    ]
  }
}

data "aws_iam_policy_document" "allow_get_url_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:Query",
    ]

    resources = [
      "${aws_dynamodb_table.urls.arn}/index/${local.codeIndex}",
    ]
  }
}

data "aws_iam_policy_document" "allow_iam_connect" {
  statement {
    effect = "Allow"

    actions = [
      "elasticache:Connect",
    ]

    resources = [
      aws_elasticache_user.main.arn,
    ]
  }
}
