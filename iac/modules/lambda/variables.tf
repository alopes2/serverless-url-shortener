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
