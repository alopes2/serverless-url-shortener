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
      "dax:Query",
    ]

    resources = [
      "${aws_dax_cluster.urls.arn}",
    ]
  }
}
