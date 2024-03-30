resource "aws_api_gateway_method" "method" {
  authorization = "NONE"
  http_method   = var.http_method
  resource_id   = var.resource_id
  rest_api_id   = var.api_id
}

resource "aws_api_gateway_integration" "integration" {
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST" # Lambda functions can only be invoked via POST
  resource_id             = var.resource_id
  rest_api_id             = var.api_id
  type                    = "AWS_PROXY"
  uri                     = var.integration_uri
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.execution_arn}/*/${aws_api_gateway_method.method.http_method}${var.resource_path}"
}

resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = var.api_id
  stage_name  = var.stage_name
  method_path = "${var.resource_path}/${aws_api_gateway_method.method.http_method}"

  settings {
    throttling_burst_limit = var.burst_limit
    throttling_rate_limit  = var.rate_limit
  }
}
