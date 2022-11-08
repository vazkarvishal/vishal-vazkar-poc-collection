resource "aws_flow_log" "vpc_1" {
  iam_role_arn    = aws_iam_role.example_log.arn
  log_destination = aws_cloudwatch_log_group.example_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}

resource "aws_flow_log" "vpc_2" {
  iam_role_arn    = aws_iam_role.example_log.arn
  log_destination = aws_cloudwatch_log_group.example_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc_2.vpc_id
}

resource "aws_flow_log" "vpc_3" {
  iam_role_arn    = aws_iam_role.example_log.arn
  log_destination = aws_cloudwatch_log_group.example_log.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc_3.vpc_id
}

resource "aws_flow_log" "tgw" {
  iam_role_arn             = aws_iam_role.example_log.arn
  log_destination          = aws_cloudwatch_log_group.example_log.arn
  traffic_type             = "ALL"
  transit_gateway_id       = aws_ec2_transit_gateway.example.id
  max_aggregation_interval = 60
}

resource "aws_cloudwatch_log_group" "example_log" {
  name              = "tgw_demo_vpc_flow_logs"
  retention_in_days = 1
}

resource "aws_iam_role" "example_log" {
  name = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "example"
  role = aws_iam_role.example_log.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
