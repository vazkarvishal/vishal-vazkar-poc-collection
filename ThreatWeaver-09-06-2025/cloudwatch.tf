resource "aws_cloudwatch_log_group" "example" {
  name = "example-log-group"
  tags = {
    Environment = "dev"
    Project     = "ThreatFret"
  }
}
