variable "aws_access_key" {
  description = "aws access key."
}

variable "aws_secret_key" {
  description = "aws secret key."
}

variable "aws_region" {
  description = "aws region."
}

variable "environment" {
  default = "staging"
}

# Route53 root zone
variable "route53_zone" {
  default = "test.com"
}
