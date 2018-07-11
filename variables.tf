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

variable "identifier" {
  default     = "drone-rds"
  description = "Identifier for your DB"
}

variable "storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "mysql"
  description = "Engine type, example values mysql, postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "db_name" {
  default     = "drone"
  description = "db name"
}

variable "username" {
  default     = "drone"
  description = "User name"
}

variable "password" {
  description = "password, provide through your ENV variables"
}
