module "create_short_url_lambda" {
  source           = "./modules/lambda"
  name             = "create-short-url"
  source_file_path = "./init_code/index.mjs"
  policies = [
    data.aws_iam_policy_document.create_short_url_lambda.json
  ]

  environment_variables = {
    BASE_URL = "https://x06h2c82x8.execute-api.eu-central-1.amazonaws.com/live/",
    SALT     = "url_shortneter"
  }
}

module "redirect_lambda" {
  source           = "./modules/lambda"
  name             = "redirect"
  source_file_path = "./init_code/index.mjs"
  policies = [
    data.aws_iam_policy_document.create_short_url_lambda.json
  ]
}
