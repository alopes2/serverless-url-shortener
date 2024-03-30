variable "http_method" {
  description = "The HTTP method"
  type        = string
}

variable "resource_id" {
  description = "The ID of the resource this method is attached to"
  type        = string
}

variable "api_id" {
  description = "The ID of the API this method is attached to"
  type        = string
}

variable "integration_uri" {
  description = "The URI of the integration this method will call"
  type        = string
}

variable "resource_path" {
  description = "The path of the resource"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function that will be called"
  type        = string
}

variable "execution_arn" {
  description = "The execution ARN of the API"
  type        = string
}

variable "stage_name" {
  description = "The stage name"
  type        = string
}

variable "burst_limit" {
  description = "Number of concurrent requests"
  type        = number
  default     = 1
}

variable "rate_limit" {
  description = "Number of request per second"
  type        = number
  default     = 1
}
