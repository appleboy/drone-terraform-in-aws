resource "aws_cloudwatch_log_group" "drone_server" {
  name = "drone/server"
}

resource "aws_cloudwatch_log_group" "drone_agent" {
  name = "drone/agent"
}
