locals {
  codeIndex = "CodeIndex"
}

resource "aws_dynamodb_table" "urls" {
  name           = "urls"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"
  range_key      = "Code"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "Code"
    type = "S"
  }

  attribute {
    name = "URL"
    type = "S"
  }

  global_secondary_index {
    name            = local.codeIndex
    hash_key        = "Code"
    range_key       = "URL"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }
}
