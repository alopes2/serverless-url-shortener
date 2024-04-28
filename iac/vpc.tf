data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0d8465c9a4387ca58"]
  }
}

data "aws_security_group" "default_security_group" {
  id = "sg-00fd9574f10291ea0"
}
