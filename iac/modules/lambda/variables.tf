variable "name" {
  description = "The name of the Lambda function"
  type        = string
  nullable    = false
}

variable "source_file_path" {
  description = "The path to the source file code"
  type        = string
}

variable "policies" {
  description = "The policies for this lambda."
  type        = list(string)
  default     = null
}

variable "environment_variables" {
  description = "The lambdas environment variables."
  type        = map(string)
  default     = null
}

variable "has_vpc" {
  description = "If a lambda function requires VPC configuration"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "The security groups for this lambda."
  type        = set(string)
  default     = null
}

variable "subnet_ids" {
  description = "The subnets for this lambda."
  type        = set(string)
  default     = null
}
