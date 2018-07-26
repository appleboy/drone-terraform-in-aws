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

variable "instance_type" {
  description = "EC2 Instance Type."
  default     = "t2.micro"
}

variable "db_name" {
  default     = "drone"
  description = "db name"
}

variable "username" {
  default     = "drone"
  description = "database user name"
}

variable "amis" {
  type = "map"

  #
  # Launching an Amazon ECS Container Instance
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
  #
  default = {
    us-east-2      = "ami-956e52f0"
    us-east-1      = "ami-5253c32d"
    us-west-2      = "ami-d2f489aa"
    us-west-1      = "ami-6b81980b"
    eu-west-2      = "ami-3622cf51"
    eu-west-3      = "ami-ca75c4b7"
    eu-west-1      = "ami-c91624b0"
    eu-central-    = "ami-10e6c8fb"
    ap-northeast-2 = "ami-7c69c112"
    ap-northeast-1 = "ami-f3f8098c"
    ap-southeast-2 = "ami-bc04d5de"
    ap-southeast-1 = "ami-b75a6acb"
    ca-central-1   = "ami-da6cecbe"
    ap-south-1     = "ami-c7072aa8"
    sa-east-1      = "ami-a1e2becd"
    us-gov-west-1  = "ami-03920462"
  }
}

variable "alb_port" {
  description = "ALB frond end port"
  default     = "80"
}

variable "task_cpu" {
  description = "cpu usage of ecs task"
  default     = "512"
}

variable "task_memory" {
  description = "memory usage of ecs task"
  default     = "1024"
}

variable "container_cpu" {
  description = "cpu usage of ecs container"
  default     = "128"
}

variable "container_memory" {
  description = "memory usage of ecs container"
  default     = "512"
}

variable "drone_server_port" {
  description = "drone server port."
  default     = "8000"
}

variable "drone_agent_port" {
  description = "drone agent comunicate port."
  default     = "9000"
}

variable "drone_github_client" {
  description = "drone github client."
}

variable "drone_github_secret" {
  description = "drone github secret."
}

variable "drone_secret" {
  description = "drone secret."
  default     = "1234567890"
}

variable "drone_version" {
  description = "drone version."
  default     = "0.8"
}

variable "drone_desired_count_agent" {
  description = "drone agent desired."
  default     = "2"
}

variable "ssh_public_key" {
  description = "The public key material. SSH public key file format as specified in RFC4716"
}
