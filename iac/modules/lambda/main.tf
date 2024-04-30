resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "DefaultPolicy"
    policy = data.aws_iam_policy_document.policies.json
  }
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = var.name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  dynamic "vpc_config" {
    for_each = var.has_vpc ? [1] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }

  environment {
    variables = var.environment_variables
  }
}
