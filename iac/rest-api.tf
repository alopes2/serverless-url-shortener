# API Gateway
resource "aws_api_gateway_rest_api" "url_shortener_api" {
  name = "url-shortener-api"
}

resource "aws_api_gateway_deployment" "url_shortener_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.url_shortener_api.root_resource_id,
      aws_api_gateway_resource.redirect_resource.id,
      module.post_url_method.id,
      module.post_url_method.integration_id,
      module.redirect_url_method.id,
      module.redirect_url_method.integration_id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "redirect_resource" {
  parent_id   = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  path_part   = "{redirectCode}"
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
}

resource "aws_api_gateway_stage" "live" {
  deployment_id = aws_api_gateway_deployment.url_shortener_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  stage_name    = "live"
}

module "post_url_method" {
  source               = "./modules/api-method"
  api_id               = aws_api_gateway_rest_api.url_shortener_api.id
  http_method          = "POST"
  resource_id          = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  resource_path        = "/"
  integration_uri      = module.create_short_url_lambda.invoke_arn
  lambda_function_name = module.create_short_url_lambda.name
  execution_arn        = aws_api_gateway_rest_api.url_shortener_api.execution_arn
  stage_name           = aws_api_gateway_stage.live.stage_name
  rate_limit           = 2
  burst_limit          = 1
}

module "redirect_url_method" {
  source               = "./modules/api-method"
  api_id               = aws_api_gateway_rest_api.url_shortener_api.id
  http_method          = "GET"
  resource_id          = aws_api_gateway_resource.redirect_resource.id
  resource_path        = aws_api_gateway_resource.redirect_resource.path
  integration_uri      = module.redirect_lambda.invoke_arn
  lambda_function_name = module.redirect_lambda.name
  execution_arn        = aws_api_gateway_rest_api.url_shortener_api.execution_arn
  stage_name           = aws_api_gateway_stage.live.stage_name
  rate_limit           = 1
  burst_limit          = 1
}
